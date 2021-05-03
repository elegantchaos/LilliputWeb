// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct InputRequest: Content {
    let command: String
}

extension PathComponent {
    static let root: PathComponent = ""
    static let input: PathComponent = "input"
    static let reset: PathComponent = "reset"
    static let undo: PathComponent = "undo"
    static let lineParameter: PathComponent = ":line"
}

struct GameController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.root, use: withUser(handleGetGame))
        routes.post(.input, use: requireUser(handlePostInput))
        routes.get(.reset, use: requireUser(handleReset))
        routes.get(.undo, .lineParameter, use: requireUser(handleUndo))
    }
    
    func handleGetGame(_ req: Request, user: User?) -> EventLoopFuture<Response> {
        let game = req.application.game
        return req.render(GamePage(user: user, game: game), user: user)
    }
    
    func handlePostInput(_ req: Request, user: User) throws -> EventLoopFuture<Response> {
        let input = try req.content.decode(InputRequest.self)
        user.history.append(input.command)
        user.history.append("\n")
        return user
            .update(on: req.db)
            .redirect(with: req, to: .root)
    }

    func handleReset(_ req: Request, user: User) throws -> EventLoopFuture<Response> {
        let transcript = user.history
        user.history = ""
        return user
            .update(on: req.db)
            .withValue(Transcript(value: transcript, userID: user.id!))
            .create(on: req.db)
            .redirect(with: req, to: .root)
    }

    func handleUndo(_ req: Request, user: User) throws -> EventLoopFuture<Response> {
        let lineIndex = try req.parameters.require("line", as: Int.self)
        let transcript = user.history.split(separator: "\n")
        let undone = transcript[..<lineIndex]
        user.history = undone.joined(separator: "\n").appending("\n")
        return user
            .update(on: req.db)
            .redirect(with: req, to: .root)
    }
}

