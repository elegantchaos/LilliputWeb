// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct ProfilePage: LeafPage {
    let users: [User]
    let tokens: [Token]
    let sessions: [SessionRecord]
    let admin: Bool
    
    init(user: User?, users: [User], tokens: [Token], sessions: [SessionRecord]) {
        self.users = users
        self.tokens = tokens
        self.sessions = sessions
        self.admin = user?.name.lowercased() == "sam"
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title: String
        let description: String

        if let user = user {
            title = "Profile: \(user.name)"
            description = "Profile page for \(user.name)."
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
        }
        return PageMetadata(title, description: description)
    }
}

