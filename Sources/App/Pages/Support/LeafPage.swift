// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

protocol LeafPage: Codable {
    var meta: PageMetadata { get }
}

extension Request {
    func render<T>(_ page: T) -> EventLoopFuture<Response> where T: LeafPage {
        let name = String(describing: T.self)
        return view.render(name, page).encodeResponse(for: self)
    }
}
