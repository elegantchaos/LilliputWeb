// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct UserAdminPage: LeafPage {
    let user: User
    let current: [String]
    let transcripts: [Transcript]
    
    init(user: User, transcripts: [Transcript]) {
        self.user = user
        self.current = user.history.split(separator: "\n").compactMap({ String($0) })
        self.transcripts = transcripts
    }
    
    func meta(for loggedInUser: User?) -> PageMetadata {
        let title: String
        let description: String

        title = "Edit User: \(user.name) (admin as \(loggedInUser!.name))"
        description = "Admin page for \(user.name)."

        return PageMetadata(title, description: description)
    }
}

