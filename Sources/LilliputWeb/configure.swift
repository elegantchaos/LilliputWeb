import Foundation
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf
import LeafKit

// configures your application
public func configure(_ app: Application) throws {

    if let databaseURL = Environment.get("DATABASE_URL"), var postgresConfig = PostgresConfiguration(url: databaseURL) {
        postgresConfig.tlsConfiguration = .forClient(certificateVerification: .none)
        app.databases.use(.postgres(
            configuration: postgresConfig
        ), as: .psql)
    } else {
        app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "vapor", database: "cases"), as: .psql)
    }
    app.sessions.use(.fluent)
    
    app.migrations.add(User.Create())
    app.migrations.add(Token.Create())
    app.migrations.add(SessionRecord.migration)
    app.migrations.add(User.AddHistory())

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))     // serve files from /Public folder

    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    let path = Bundle.module.url(forResource: "Views", withExtension: nil)!.path
    let source = NIOLeafFiles(fileio: app.fileio,
                              limits: .default,
                              sandboxDirectory: path,
                              viewDirectory: path)

    let sources = app.leaf.sources
    try sources.register(source: "builtin", using: source, searchable: true)
    app.leaf.sources = sources
    print(app.leaf.sources.searchOrder)

    // register routes
    try routes(app)
    
    app.users.use { req in DatabaseUserRepository(database: req.db) }
    app.tokens.use { req in DatabaseTokenRepository(database: req.db) }

    if app.environment == .development {
        try app.autoMigrate().wait()
    }

}
