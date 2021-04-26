// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct ProfilePage: LeafPage {
    var file: String
    var meta: PageMetadata
    let user: User?
    let users: [User]
    let tokens: [Token]
    let sessions: [SessionRecord]
    let history: [String]
    
    init(user: User?, users: [User], tokens: [Token], sessions: [SessionRecord]) {
        let title: String
        let description: String
        let history: [String]
        if let user = user {
            title = "Logged in as \(user.name)."
            description = "Profile page for \(user.name)."
            history = user.history.split(separator: "\n").compactMap({ String($0) })
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
            history = []
        }

        self.user = user
        self.file = "profile"
        self.meta = .init(title, description: description)
        self.users = users
        self.tokens = tokens
        self.sessions = sessions
        self.history = history
    }
}

