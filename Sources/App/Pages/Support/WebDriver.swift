// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import ExampleGames

class WebDriver: Driver {
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
    
    static func run(history: [String]) -> [String] {
        let driver = WebDriver()
        let engine = Engine(driver: driver)
        let url = ExampleGames.urlForGame(named: "StrangeCases")!
        engine.load(url: url)
        
        driver.input = history
        engine.run()
        driver.finish()
        
        return driver.full.dropLast(3)
    }
}
