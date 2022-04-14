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
    static let editObject: PathComponent = "edit-object"
    static let objectParameter: PathComponent = ":object"
//    static let adminTokens: PathComponent = "admin-tokens"
//    static let adminSessions: PathComponent = "admin-sessions"
}

//struct UpdateUserResponse: Codable {
//    let name: String
//    let email: String
//    let roles: String
//}

struct EditorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.editor, use: requireUser(handleGetOverview))
        routes.get(.editObject, .objectParameter, use: requireUser(handleGetEditObject))
        routes.post(.editObject, .objectParameter, use: requireUser(handlePostEditObject))
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
    
    func handleGetEditObject(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let objectID = try req.parameters.require("object", as: String.self)
        let page = EditObjectPage(game: req.application.game, objectID: objectID)
        return req.render(page, user: loggedInUser)
    }

    func handlePostEditObject(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let response = try req.content.decode(AdminUserPage.FormData.self)

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
            .thenRedirect(with: req, to: .adminIndex)
    }
}
