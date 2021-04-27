// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

protocol LeafPage: Codable {
    func meta(for user: User?) -> PageMetadata
}

struct Site: Codable {
    let title: String
}

struct RenderContext<Page>: Codable where Page: LeafPage {
    internal init(page: Page, user: User?, error: String?, game: GameConfiguration) {
        let file = String(describing: Page.self)

        self.site = Site(title: game.name)
        self.meta = page.meta(for: user)
        self.file = file
        self.page = page
        self.user = user
        self.error = error
        self.isAdmin = user?.isAdmin ?? false
    }
    
    let site: Site
    let meta: PageMetadata
    let file: String
    let page: Page
    let user: User?
    let error: String?
    let isAdmin: Bool
}

extension Request {
    func render<T>(_ page: T, user: User? = nil, error: Error? = nil) -> EventLoopFuture<Response> where T: LeafPage {
        let context = RenderContext(page: page, user: user, error: error?.localizedDescription, game: application.game)
        return view.render(context.file, context).encodeResponse(for: self)
    }
}
