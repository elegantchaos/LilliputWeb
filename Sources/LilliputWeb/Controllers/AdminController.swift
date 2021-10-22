// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

enum AdminError: String, DebuggableError {
    case unknownUser
    case notAdmin
    
    var identifier: String {
        rawValue
    }
    
    var reason: String {
        rawValue
    }
    
}




extension PathComponent {
    static let admin: PathComponent = "admin"
    static let adminUser: PathComponent = "admin-user"
    static let userParameter: PathComponent = ":user"
}

struct UpdateUserResponse: Codable {
    let name: String
    let email: String
    let roles: String
}

struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.admin, use: requireUser(handleGetOverview))
        routes.get(.adminUser, .userParameter, use: requireUser(handleGetUser))
        routes.post(.adminUser, .userParameter, use: requireUser(handleUpdateUser))
    }
    
    func unpack(_ data: ((([Token], [SessionRecord]), [User]), [Transcript])) -> ([Token], [SessionRecord], [User], [Transcript]) {
        let (tsu, transcripts) = data
        let (ts, users) = tsu
        let (tokens, sessions) = ts
        return (tokens, sessions, users, transcripts)
    }
    
    func handleGetOverview(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }
            
        return req.tokens.all()
            .and(SessionRecord.query(on: req.db).all())
            .and(req.users.all())
            .and(req.transcripts.all())
            .flatMap { data in
                let (tokens, sessions, users, transcripts) = self.unpack(data)
                let page = AdminPage(user: loggedInUser, users: users, tokens: tokens, sessions: sessions, transcripts: transcripts)
                return req.render(page, user: loggedInUser)
            }
    }
    
    func handleGetUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let userID = try req.parameters.require("user", as: UUID.self)
        let user = User.query(on: req.db).filter(\.$id == userID).first()
        return user
            .unwrap(or: AdminError.unknownUser)
            .flatMap { examinedUser in req.render(UserAdminPage(user: examinedUser), user: loggedInUser) }
    }

    func handleUpdateUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let response = try req.content.decode(UpdateUserResponse.self)

        let userID = try req.parameters.require("user", as: UUID.self)
        let user = User.query(on: req.db).filter(\.$id == userID).first()
        return user
            .unwrap(or: AdminError.unknownUser)
            .map { (updatedUser: User) -> EventLoopFuture<Void> in
                updatedUser.name = response.name
                updatedUser.email = response.email
                updatedUser.roles = response.roles
                
                return updatedUser.save(on: req.db)
            }
            .thenRedirect(with: req, to: .admin)
    }
}
