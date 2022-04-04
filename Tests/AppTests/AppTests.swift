import LilliputExamples

@testable import LilliputWeb
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        print(FileManager.default.currentDirectoryPath)

        let name = "ChairTest"
        let url = LilliputExamples.urlForGame(named: name)!
        let game = GameConfiguration(name: name, url: url, database: "test")
        try configure(app, game: game)

        try app.test(.GET, "/") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertTrue(res.body.string.contains(game.name))
        }
    }
}
