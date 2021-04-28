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
    
    func unpack(_ data: ((([Token], [SessionRecord]), [User]), [Transcript])) -> ([Token], [SessionRecord], [User], [Transcript]) {
        let (tsu, transcripts) = data
        let (ts, users) = tsu
        let (tokens, sessions) = ts
        return (tokens, sessions, users, transcripts)
    }
    
    func handleGetAdmin(_ req: Request, for user: User) -> EventLoopFuture<Response> {
        print("test")
        return req.tokens.all()
            .and(SessionRecord.query(on: req.db).all())
            .and(req.users.all())
            .and(req.transcripts.all())
            .flatMap { data in
                let (tokens, sessions, users, transcripts) = self.unpack(data)
                let page = AdminPage(user: user, users: users, tokens: tokens, sessions: sessions, transcripts: transcripts)
                return req.render(page, user: user)
            }
    }
}
