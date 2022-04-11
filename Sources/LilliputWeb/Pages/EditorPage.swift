// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

public extension StringTable {
    var editableStrings: [String: [String]] {
        return [:]
    }
}
struct EditableObject: Codable {
    let id: String
    let name: String
    let strings: [String: [String]]
    
    init(_ object: Object) {
        id = object.id
        name = object.getDefinite()
        strings = object.definition.strings.editableStrings
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


