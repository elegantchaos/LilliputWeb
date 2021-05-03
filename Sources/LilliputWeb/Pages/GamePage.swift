// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct GamePage: LeafPage {
    let transcript: [TranscriptLine]
    var prompt: String

    struct TranscriptLine: Codable {
        let index: Int?
        let text: [String]
        let type: String

        init(_ line: WebDriver.Line, index: inout Int) {
            self.text = line.text.split(separator: "\n").map(as: String.self)
            self.type = String(describing: line.type)
            if line.type == .input {
                self.index = index
                index += 1
            } else {
                self.index = nil
            }
        }
    }
    
    init(user: User? = nil, game: GameConfiguration) {
        let history: [String]
        if let user = user {
            history = user.history.split(separator: "\n").compactMap({ String($0) })
        } else {
            history = []
        }

        var prompt: String?
        func filterPrompts(_ line: WebDriver.Line) -> Bool {
            if line.type == .prompt {
                prompt = line.text
                return false
            } else {
                prompt = nil
                return true
            }
        }

        let lines = WebDriver.run(history: history, url: game.url).dropLast(2)
        var index = 0
        let transcript = lines
            .filter(filterPrompts)
            .map({ TranscriptLine($0, index: &index)})

        self.transcript = transcript
        self.prompt = prompt ?? "some common commands: <b>go</b> <i>direction</i>, <b>look</b>, <b>inventory</b>, <b>take</b>/<b>drop</b>/<b>use</b>/<b>open</b>/<b>unlock</b> <i>object</i>."
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

