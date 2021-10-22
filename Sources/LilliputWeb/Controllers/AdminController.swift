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
    static let adminTokens: PathComponent = "admin-tokens"
    static let adminSessions: PathComponent = "admin-sessions"
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
        routes.get(.adminTokens, use: requireUser(handleGetTokens))
        routes.get(.adminSessions, use: requireUser(handleGetSessions))
        routes.get(.adminUser, .userParameter, use: requireUser(handleGetUser))
        routes.post(.adminUser, .userParameter, use: requireUser(handleUpdateUser))
    }
    
    func unpack(_ data: (([SessionRecord], [User]), [Transcript])) -> ([SessionRecord], [User], [Transcript]) {
        let (tsu, transcripts) = data
        let (sessions, users) = tsu
        return (sessions, users, transcripts)
    }
    
    func handleGetOverview(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }
            
        return req.users.all()
            .flatMap { users in
                let page = AdminPage(users: users)
                return req.render(page, user: loggedInUser)
            }
    }

    func handleGetTokens(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }
            
        return Token.query(on: req.db).with(\.$user).all()
            .flatMap { tokens in
                let page = TokenAdminPage(tokens: tokens)
                return req.render(page, user: loggedInUser)
            }
    }

    func handleGetSessions(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }
            
        return SessionRecord.query(on: req.db).all()
            .flatMap { sessions in
                let page = SessionAdminPage(sessions: sessions)
                return req.render(page, user: loggedInUser)
            }
    }

    func handleGetUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let userID = try req.parameters.require("user", as: UUID.self)
//        let transcripts = Transcript
//            .query(on: req.db)
//            .filter(\.user.$id == userID)
//
        let user = User.query(on: req.db).filter(\.$id == userID).first()
        return user
            .unwrap(or: AdminError.unknownUser)
            .and(req.transcripts.all().map({ $0.filter({ $0.user.id == userID }) }))
            .flatMap { (examinedUser, transcripts) in
                req.render(UserAdminPage(user: examinedUser, transcripts: transcripts), user: loggedInUser) }
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
