// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/10/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct SplashPage: LeafPage {
    init(user: User? = nil) {
    }

    func meta(for user: User?) -> PageMetadata {
        let title = "Strange Cases"
        let description = "Strange Cases Splash Screen"
        return .init(title, description: description)
    }
}

