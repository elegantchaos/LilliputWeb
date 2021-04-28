// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension User {
    static var createMigration: Fluent.Migration {
        SimpleMigration("CreateUser", for: self) { schema in
            schema
                .id()
                .field(.name, .string, .required)
                .field(.email, .string, .required)
                .field(.passwordHash, .string, .required)
                .unique(on: .name)
                .create()

        } revert: { schema in
            schema.delete()
        }
    }
}
