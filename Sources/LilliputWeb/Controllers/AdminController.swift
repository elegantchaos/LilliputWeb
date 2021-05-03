// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

enum AdminError: String, DebuggableError {
    case unknownUser

    var identifier: String {
        rawValue
    }
    
    var reason: String {
        rawValue
    }
    
}




extension PathComponent {
    static let admin: PathComponent = "admin"
    static let adminUser: PathComponent = "admin-user"
    static let userParameter: PathComponent = ":user"
}

struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.admin, use: requireUser(handleGetAdmin))
        routes.get(.adminUser, .userParameter, use: requireUser(handleGetAdminUser))
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
    
    func handleGetAdminUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        let otherID = try req.parameters.require("user", as: UUID.self)
        let user = User.query(on: req.db).filter(\.$id == otherID).first()
        return user
            .unwrap(or: AdminError.unknownUser)
            .flatMap { examinedUser in req.render(UserAdminPage(user: examinedUser), user: loggedInUser) }
    }
}
