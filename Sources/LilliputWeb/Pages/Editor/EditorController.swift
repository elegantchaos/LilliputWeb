// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
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
        let session = editSessionForObject(withID: objectID, game: req.application.game)
        let page = EditObjectPage(session: session)
        return req.render(page, user: loggedInUser)
    }

    func handlePostEditObject(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let properties = try req.content.decode([String:String].self)
        let objectID = try req.parameters.require("object", as: String.self)
        let game = req.application.game
        updateObject(withID: objectID, properties: properties, game: game)
        let session = editSessionForObject(withID: objectID, game: game)
        let page = EditObjectPage(session: session)
        return req.render(page, user: loggedInUser)
    }
    
    func editSessionForObject(withID objectID: String, game: GameConfiguration) -> EditSession {
        let driver = BasicDriver()
        let engine = Engine(driver: driver)
        engine.load(url: game.url)
        engine.setup()
        
        let object = engine.object(withID: objectID)
        let session = EditSession(for: object)
        return session
    }
    
    func updateObject(withID objectID: String, properties: [String:String], game: GameConfiguration) {
        let driver = BasicDriver()
        let engine = Engine(driver: driver)
        engine.load(url: game.url)
        engine.setup()
        
        let object = engine.object(withID: objectID)
        object.definition.update(fromEditSubmission: properties)
    }
}
