// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import Foundation

class WebDriver: Driver {
    enum LineType {
        case input
        case output
        case error
    }
    
    struct Line {
        let type: LineType
        let text: String
    }
    
    let showOutput = false
    var input: [String] = []
    var output: [String] = []
    var transcript: [Line] = []
    var current: String = ""
    
    func getInput(stopWords: [String.SubSequence]) -> Input {
        guard let string = input.first else { return Input("quit", stopWords: stopWords)! }
        
        input.remove(at: 0)
        transcript.append(Line(type: .input, text: string))
        return Input(string, stopWords: [])!
    }
    
    func output(_ string: String, newParagraph: Bool) {
        current.append(string)
        if newParagraph {
            output.append(current)
            transcript.append(Line(type: .output, text: current))
            current = ""
        }
    }
    
    func finish() {
        if !current.isEmpty {
            output("", newParagraph: true)
        }
        
        if showOutput {
            print(output)
        }
    }
    
    static func run(history: [String], url: URL? = nil) -> [Line] {
        let driver = WebDriver()
        let engine = Engine(driver: driver)
        
        engine.load(url: url ?? URL(fileURLWithPath: "Resources/Games/StrangeCases"))
        
        driver.input = history
        engine.run()
        driver.finish()
        
        return driver.transcript.dropLast()
    }
}
