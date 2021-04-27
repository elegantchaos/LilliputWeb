// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let settings: PathComponent = "settings"
    static let logout: PathComponent = "logout"
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.settings, use: handleGetSettings)
        routes.put(.settings, use: handleUpdateSettings)
        routes.get(.logout, use: handleLogout)
    }
    
    func handleGetSettings(_ req: Request) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            return token.$user.get(on: req.db)
                .flatMap { user in self.renderProfilePage(req, for: user) }
        } else {
            return self.renderProfilePage(req)
        }
    }

    func handleUpdateSettings(_ req: Request) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            return token.$user.get(on: req.db)
                .flatMap { user in self.renderProfilePage(req, for: user) }
        } else {
            return self.renderProfilePage(req)
        }
    }

    func handleLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: "/login")
    }

    func renderProfilePage(_ req: Request, for user: User? = nil) -> EventLoopFuture<Response> {
        return req.tokens.all()
            .and(SessionRecord.query(on: req.db).all())
            .and(req.users.all())
            .flatMap { (tokensAndSessions, users) in
                let (tokens, sessions) = tokensAndSessions
                let page = ProfilePage(user: user, users: users, tokens: tokens, sessions: sessions)
                return req.render(page, user: user)
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


}
