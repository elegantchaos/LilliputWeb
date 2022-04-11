// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import Foundation

class WebDriver: Driver {
    struct Line {
        let type: OutputType
        let text: String
    }
    
    let showOutput = false
    var input: [String] = []
    var transcript: [Line] = []
    
    func getInput(stopWords: [String.SubSequence]) -> Input {
        guard let string = input.first else { return Input("quit", stopWords: stopWords)! }
        
        input.remove(at: 0)
        return Input(string.lowercased(), stopWords: [])!
    }
    
    func output(_ string: String, type: OutputType) {
        transcript.append(Line(type: type, text: string))
    }
    
    func finish() {
        if showOutput {
            print(output)
        }
    }
    
    static func defaultURL() -> URL {
        guard let url = Bundle.main.url(forResource: "Game", withExtension: nil) else {
            fatalError("Couldn't find game resources.")
        }
        
        return url
    }
    
    static func run(history: [String], url: URL? = nil) -> [Line] {
        let driver = WebDriver()
        let engine = Engine(driver: driver)
        
        
        engine.load(url: url ?? defaultURL())
        
        driver.input = history
        engine.run()
        driver.finish()
        
        return driver.transcript.dropLast()
    }
}
