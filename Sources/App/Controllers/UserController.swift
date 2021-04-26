import Fluent
import Vapor


struct InputRequest: Content {
    let command: String
}

struct UserController: RouteCollection {
    let sessionProtected: RoutesBuilder
    
    func boot(routes: RoutesBuilder) throws {
        sessionProtected.get("", use: renderProfile)
        sessionProtected.post("input", use: performInput)
        sessionProtected.get("logout", use: performLogout)
    }
    
    func renderProfile(_ req: Request) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            return token.$user.get(on: req.db)
                .flatMap { user in self.renderProfilePage(req, for: user) }
        } else {
            return self.renderProfilePage(req)
        }
    }
    
    func renderProfilePage(_ req: Request, for user: User? = nil) -> EventLoopFuture<Response> {
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
    
    
    func performLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: "/login")
    }
}
