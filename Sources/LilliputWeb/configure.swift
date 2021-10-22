import Foundation
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf
import LeafKit

// configures your application

public func configure(_ app: Application, game: GameConfiguration) throws {

    if let databaseURL = Environment.get("DATABASE_URL"), var postgresConfig = PostgresConfiguration(url: databaseURL) {
        postgresConfig.tlsConfiguration = .forClient(certificateVerification: .none)
        app.databases.use(.postgres(
            configuration: postgresConfig
        ), as: .psql)
    } else {
        app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "vapor", database: "cases"), as: .psql)
    }
    app.sessions.use(.fluent)
    
    setupMigrations(app)
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))     // serve files from /Public folder

    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    let path = Bundle.module.url(forResource: "Views", withExtension: nil)!.path
    print("LilliputWeb built-in views path is: \(path)")
    let source = NIOLeafFiles(fileio: app.fileio,
                              limits: [.toSandbox, .requireExtensions], // Heroku bundle files are inside `.swift-bin`, which can be mistaken for being invisible
                              sandboxDirectory: path,
                              viewDirectory: path)

    let sources = app.leaf.sources
    try sources.register(source: "builtin", using: source, searchable: true)
    app.leaf.sources = sources

    // register routes
    try routes(app)
    
    app.users.use { req in DatabaseUserRepository(database: req.db) }
    app.tokens.use { req in DatabaseTokenRepository(database: req.db) }
    app.transcripts.use { req in DatabaseTranscriptRepository(database: req.db) }
    
    app.game = game
    
    if app.environment == .development {
        try app.autoMigrate().wait()
    }

}

fileprivate func setupMigrations(_ app: Application) {
    app.migrations.add(User.createMigration)
    app.migrations.add(Token.createMigration)
    app.migrations.add(SessionRecord.migration)
    app.migrations.add(User.addHistoryMigration)
    app.migrations.add(Transcript.createMigration)
    app.migrations.add(User.makeEmailUnique)
    app.migrations.add(User.addUserRoles)
}


public struct GameConfiguration {
    let name: String
    let url: URL

    public init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

struct GameConfigurationKey: StorageKey {
    typealias Value = GameConfiguration
}
extension Application {
    var game: GameConfiguration {
        get {
            self.storage[GameConfigurationKey.self]!
        }
        
        set {
            self.storage[GameConfigurationKey.self] = newValue
        }
    }
}
