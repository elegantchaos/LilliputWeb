// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct GamePage: LeafPage {
    let transcript: [TranscriptLine]
    
    struct TranscriptLine: Codable {
        let text: [String]
        let type: String
        
        init(_ line: WebDriver.Line) {
            text = line.text.split(separator: "\n").map(as: String.self)
            type = String(describing: line.type)
        }
    }
    
    init(user: User? = nil) {
        let history: [String]
        if let user = user {
            history = user.history.split(separator: "\n").compactMap({ String($0) })
        } else {
            history = []
        }
        
        let lines = WebDriver.run(history: history)
        self.transcript = lines.map({ TranscriptLine($0)})
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title: String
        let description: String
        if let user = user {
            title = "Strange Cases…"
            description = "Profile page for \(user.name)."
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
        }

        return .init(title, description: description)
    }
}

