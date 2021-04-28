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
        routes.get(.settings, use: requireUser(renderProfilePage))
        routes.post(.settings, use: handleUpdateSettings)
        routes.get(.logout, use: handleLogout)
    }
    
    func handleUpdateSettings(_ req: Request) throws -> EventLoopFuture<Response> {
        req.redirectFuture(to: .settings)
    }

    func handleLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: .login)
    }

    func renderProfilePage(_ req: Request, for user: User) -> EventLoopFuture<Response> {
        return req.render(ProfilePage(user: user), user: user)
    }
}
