// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct HelpPage: LeafPage {
    func meta(for user: User?) -> PageMetadata {
        let title = "Strange Cases… Help"
        let description = "Help Page for Strange Cases."
        return .init(title, description: description)
    }
}

