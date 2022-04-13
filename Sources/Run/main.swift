import LilliputExamples
import LilliputWeb
import Vapor

let name = Environment.get("GAME_NAME") ?? "ChairTest"
let database = Environment.get("GAME_NAME") ?? "test"
let game = GameConfiguration(name: name, url: LilliputExamples.urlForGame(named: name)!, database: database)
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app, game: game)

try app.run()
