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
}

struct GameController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.root, use: withUser(handleGetGame))
        routes.post(.input, use: requireUser(handlePostInput))
        routes.get(.reset, use: requireUser(handleReset))
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

}

