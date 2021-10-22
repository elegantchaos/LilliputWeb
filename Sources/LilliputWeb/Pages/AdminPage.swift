// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct AdminPage: LeafPage {
    let users: [User]
    let tokens: [Token]
    let sessions: [SessionRecord]
    let transcripts: [Transcript]
    
    init(user: User?, users: [User], tokens: [Token], sessions: [SessionRecord], transcripts: [Transcript]) {
        self.users = users
        self.tokens = tokens
        self.sessions = sessions
        self.transcripts = transcripts
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title: String
        let description: String

        if let user = user {
            title = "Admin: \(user.name)"
            description = "Admin page for \(user.name)."
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
        }
        return PageMetadata(title, description: description)
    }
}

