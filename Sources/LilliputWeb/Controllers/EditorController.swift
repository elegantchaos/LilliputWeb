// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

enum EditorError: String, DebuggableError {
    case unknownUser
    case notEditor
    
    var identifier: String {
        rawValue
    }
    
    var reason: String {
        rawValue
    }
    
}




extension PathComponent {
    static let editor: PathComponent = "editor"
//    static let adminUser: PathComponent = "admin-user"
//    static let adminTokens: PathComponent = "admin-tokens"
//    static let adminSessions: PathComponent = "admin-sessions"
//    static let userParameter: PathComponent = ":user"
}

//struct UpdateUserResponse: Codable {
//    let name: String
//    let email: String
//    let roles: String
//}

struct EditorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.editor, use: requireUser(handleGetOverview))
//        routes.get(.adminTokens, use: requireUser(handleGetTokens))
//        routes.get(.adminSessions, use: requireUser(handleGetSessions))
//        routes.get(.adminUser, .userParameter, use: requireUser(handleGetUser))
//        routes.post(.adminUser, .userParameter, use: requireUser(handleUpdateUser))
    }
    
    func unpack(_ data: (([SessionRecord], [User]), [Transcript])) -> ([SessionRecord], [User], [Transcript]) {
        let (tsu, transcripts) = data
        let (sessions, users) = tsu
        return (sessions, users, transcripts)
    }
    
    func handleGetOverview(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isEditor else {
            return req.eventLoop.makeFailedFuture(EditorError.notEditor)
        }
        
        return req.users.all()
            .flatMap { users in
                let page = EditorPage(game: req.application.game)
                return req.render(page, user: loggedInUser)
            }
    }
    
//    func handleGetTokens(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
//        guard loggedInUser.isAdmin else {
//            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
//        }
//
//        return Token.query(on: req.db).with(\.$user).all()
//            .flatMap { tokens in
//                let page = TokenAdminPage(tokens: tokens)
//                return req.render(page, user: loggedInUser)
//            }
//    }
//
//    func handleGetSessions(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
//        guard loggedInUser.isAdmin else {
//            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
//        }
//
//        return SessionRecord.query(on: req.db).all()
//            .flatMap { sessions in
//                let page = SessionAdminPage(sessions: sessions)
//                return req.render(page, user: loggedInUser)
//            }
//    }
//
//    func handleGetUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
//        guard loggedInUser.isAdmin else {
//            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
//        }
//
//        let userID = try req.parameters.require("user", as: UUID.self)
//        let transcripts = Transcript
//            .query(on: req.db)
//            .with(\.$user)
//            .filter(\.$user.$id == userID)
//            .all()
//
//        let user = User.query(on: req.db).filter(\.$id == userID).first()
//        return user
//            .unwrap(or: AdminError.unknownUser)
//            .and(transcripts)
//            .flatMap { (user, transcripts) in
//                req.render(UserAdminPage(user: user, transcripts: transcripts), user: loggedInUser) }
//    }
//
//    func handleUpdateUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
//        guard loggedInUser.isAdmin else {
//            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
//        }
//
//        let response = try req.content.decode(UpdateUserResponse.self)
//
//        let userID = try req.parameters.require("user", as: UUID.self)
//        let user = User.query(on: req.db).filter(\.$id == userID).first()
//        return user
//            .unwrap(or: AdminError.unknownUser)
//            .map { (updatedUser: User) -> EventLoopFuture<Void> in
//                updatedUser.name = response.name
//                updatedUser.email = response.email
//                updatedUser.roles = response.roles
//
//                return updatedUser.save(on: req.db)
//            }
//            .thenRedirect(with: req, to: .admin)
//    }
}
