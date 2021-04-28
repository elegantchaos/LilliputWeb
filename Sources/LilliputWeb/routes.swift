import Fluent
import Vapor

func routes(_ app: Application) throws {
//     let sessionEnabled = app.grouped(
//         SessionsMiddleware(session: app.sessions.driver)
//     )
//
     let sessionProtected = app.grouped(
         SessionsMiddleware(session: app.sessions.driver),
         Token.sessionAuthenticator()
     )
    
    try app.register(collection: LoginController())
    try sessionProtected.register(collection: UserController())
    try sessionProtected.register(collection: GameController())
    try sessionProtected.register(collection: AdminController())
    try app.register(collection: RegistrationController())
}
