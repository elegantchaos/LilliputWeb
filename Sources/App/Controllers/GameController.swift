// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct InputRequest: Content {
    let command: String
}

struct GameController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: renderGame)
        routes.post("input", use: performInput)
        routes.get("reset", use: performReset)
    }
    
    func renderGame(_ req: Request) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            return token.$user.get(on: req.db)
                .flatMap { user in self.renderGamePage(req, for: user) }
        } else {
            return self.renderGamePage(req)
        }
    }
    
    func renderGamePage(_ req: Request, for user: User? = nil) -> EventLoopFuture<Response> {
        return req.tokens.all()
            .and(SessionRecord.query(on: req.db).all())
            .and(req.users.all())
            .flatMap { (tokensAndSessions, users) in
                let (tokens, sessions) = tokensAndSessions
                let page = ProfilePage(user: user, users: users, tokens: tokens, sessions: sessions)
                return page.render(with: req)
            }
    }
    
    func updateHistory(_ req: Request, user: User, input: InputRequest) -> EventLoopFuture<Void> {
        user.history.append(input.command)
        user.history.append("\n")
        return user.update(on: req.db)
    }

    func resetHistory(_ req: Request, user: User) -> EventLoopFuture<Void> {
        user.history = ""
        return user.update(on: req.db)
    }

    func performInput(_ req: Request) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            do {
                let input = try req.content.decode(InputRequest.self)
                return token.$user.get(on: req.db)
                    .flatMap { user in self.updateHistory(req, user: user, input: input) }
                    .thenRedirect(with: req, to: "/")
            } catch {
            }
        }

        return req.eventLoop.makeSucceededFuture(req.redirect(to: "/"))
    }

    func performReset(_ req: Request) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            return token.$user.get(on: req.db)
                .flatMap { user in self.resetHistory(req, user: user) }
                .thenRedirect(with: req, to: "/")
        }

        return req.eventLoop.makeSucceededFuture(req.redirect(to: "/"))
    }

}
