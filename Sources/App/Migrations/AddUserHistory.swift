// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import FluentSQL
import Vapor

extension User {
    struct AddHistory: Fluent.Migration {
        var name: String { "AddUserHistory" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            let defaultValue = SQLColumnConstraintAlgorithm.default("")
            return database.schema(User.schema)
                .field(.history, .string, .sql(defaultValue))
                .update()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(User.schema)
                .deleteField(.history)
                .update()
        }
    }
}
