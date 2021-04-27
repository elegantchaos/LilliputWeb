// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import ExampleGames
import Vapor


class TestDriver: Driver {
    
    let showOutput = false
    var input: [String] = []
    var output: [String] = []
    var full: [String] = []
    
    func getInput(stopWords: [String.SubSequence]) -> Input {
        guard let string = input.first else { return Input("quit", stopWords: stopWords)! }
        
        input.remove(at: 0)
        full.append("> \(string)\n\n")
        return Input(string, stopWords: [])!
    }
    
    func output(_ string: String, newParagraph: Bool) {
        output.append(string)
        full.append(string)
        if newParagraph {
            output.append("\n\n")
            full.append("\n\n")
        }
    }
    
    func finish() {
        if showOutput {
            print(output)
            print(full.joined())
        }
    }
    
}

struct GamePage: LeafPage {
    var file: String
    var meta: PageMetadata
    let user: User?
    let transcript: [String]
    
    init(user: User?) {
        let title: String
        let description: String
        let history: [String]
        if let user = user {
            title = "Strange Cases…"
            description = "Profile page for \(user.name)."
            history = user.history.split(separator: "\n").compactMap({ String($0) })
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
            history = []
        }

        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = ExampleGames.urlForGame(named: "StrangeCases")!
        engine.load(url: url)
        
        driver.input = history
        engine.run()
        driver.finish()
        
        self.user = user
        self.file = "game"
        self.meta = .init(title, description: description)
        self.transcript = driver.full.dropLast(3)
    }
}

