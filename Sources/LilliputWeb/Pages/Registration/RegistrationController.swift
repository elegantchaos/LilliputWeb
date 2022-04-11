// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor
import Fluent

struct RegistrationRequest: Content {
    let name: String
    let email: String
    let password: String
    let confirm: String
    
    func hash(with req: Request) -> EventLoopFuture<String> {
        return req.password.async.hash(password)
    }
}

extension RegistrationRequest: Validatable {
    static func decode(from req: Request) throws -> RegistrationRequest {
        try RegistrationRequest.validate(content: req)
        let request = try req.content.decode(RegistrationRequest.self)
        guard request.password == request.confirm else {
            throw AuthenticationError.passwordsDontMatch
        }
        return request
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(4...))
    }
}

extension PathComponent {
    static let register: PathComponent = "register"
}

struct RegistrationController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(.register, use: renderRegister)
        routes.post(.register, use: handleRegister)
    }
    
    func renderRegister(req: Request) throws -> EventLoopFuture<Response> {
        return req.render(RegisterPage())
    }
    
    func handleRegister(_ req: Request) throws -> EventLoopFuture<Response> {
        let registration = try RegistrationRequest.decode(from: req)
        
        return registration.hash(with: req)
            .withNewUser(using: registration, with: req)
            .create(on: req.db)
            .translatingError(to: AuthenticationError.emailAlreadyExists, if: { (error: DatabaseError) in error.isConstraintFailure })
            .redirect(with: req, to: .login)
    }
    
}


fileprivate extension EventLoopFuture where Value == String {
    func withNewUser(using registration: RegistrationRequest, with req: Request) -> EventLoopFuture<User>  {
        flatMapThrowing { hash in User(name: registration.name, email: registration.email, passwordHash: hash) }
            .translatingError(to: AuthenticationError.emailAlreadyExists, if: { (error: DatabaseError) in error.isConstraintFailure })
    }

}
