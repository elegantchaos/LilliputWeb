// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
import Vapor
import Fluent

extension FieldKey {
    static var name: FieldKey = "name"
    static var email: FieldKey = "email"
    static var history: FieldKey = "history"
    static var passwordHash: FieldKey = "password_hash"
}

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: .name)
    var name: String

    @Field(key: .email)
    var email: String

    @Field(key: .passwordHash)
    var passwordHash: String

    @Field(key: .history)
    var history: String
    
    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.history = ""
    }
    
    var isAdmin: Bool {
        name.lowercased() == "sam"
    }
}

extension User {
    func generateToken() throws -> Token {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
