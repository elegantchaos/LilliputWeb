// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct EditableString: Codable {
    static let multilineFields = ["location", "detailed"]
    static let labels = [
        "definite": "Definite Name",
        "indefinite": "Indefinite Name",
        "location": "Location Description",
        "detailed": "Object Description"
    ]
    
    let key: String
    let label: String
    let values: [String]
    let multiline: Bool
    
    init(key: String, values: StringAlternatives) {
        self.key = key
        self.values = values.strings
        self.multiline = Self.multilineFields.contains(key)
        self.label = Self.labels[key] ?? key
    }
}

struct EditableObject: Codable {
    let id: String
    let name: String
    let strings: [EditableString]
    
    init(_ object: Object) {
        id = object.id
        name = object.getDefinite()
        strings = object.definition.strings.table.map({ EditableString(key: $0.key, values: $0.value) })
    }
}

struct EditorPage: LeafPage {
    let objects: [EditableObject]
    
    init(game: GameConfiguration) {
        let driver = BasicDriver()
        let engine = Engine(driver: driver)
        engine.load(url: game.url)
        engine.setup()
        
        objects = engine.editableObjects.map({ EditableObject($0) })
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title: String
        let description: String
        
        if let user = user {
            title = "Editor"
            description = "Editor page for \(user.name)."
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
        }
        return PageMetadata(title, description: description)
    }
}


