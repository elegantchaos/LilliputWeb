// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let admin: PathComponent = "admin"
}

struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.admin, use: requireUser(handleGetAdmin))
    }
    
    func handleGetAdmin(_ req: Request, for user: User? = nil) -> EventLoopFuture<Response> {
        return req.tokens.all()
            .and(SessionRecord.query(on: req.db).all())
            .and(req.users.all())
            .flatMap { (tokensAndSessions, users) in
                let (tokens, sessions) = tokensAndSessions
                let page = AdminPage(user: user, users: users, tokens: tokens, sessions: sessions)
                return req.render(page, user: user)
            }
    }
}
