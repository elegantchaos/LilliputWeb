// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/10/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let splash: PathComponent = "splash"
}

struct SplashController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.root, use: withUser(handleGetSplash))
        routes.get(.splash, use: withUser(handleGetSplash))
    }

    func handleGetSplash(_ req: Request, user: User?) -> EventLoopFuture<Response> {
        return req.render(SplashPage(), user: user)
    }
}


