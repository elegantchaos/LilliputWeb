// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct TokenAdminPage: LeafPage {
    let tokens: [Token]
    
    init(user: User?, tokens: [Token]) {
        self.tokens = tokens
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title: String
        let description: String

        if let user = user {
            title = "Token Admin: \(user.name)"
            description = "Token admin page for \(user.name)."
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
        }
        return PageMetadata(title, description: description)
    }
}

