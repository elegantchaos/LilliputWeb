import LilliputExamples
import LilliputWeb
import Vapor

let game = GameConfiguration(name: "Strange Cases", url: LilliputExamples.urlForGame(named: "ChairTest")!, database: "test")
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app, game: game)
try app.run()
