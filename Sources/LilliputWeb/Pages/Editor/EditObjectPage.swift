// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct EditObjectPage: LeafPage {
    let object: EditableObject
    
    init(game: GameConfiguration, objectID: String) {
        let driver = BasicDriver()
        let engine = Engine(driver: driver)
        engine.load(url: game.url)
        engine.setup()
        
        object = EditableObject(engine.object(withID: objectID))
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title = "Object: \(object.id)"
        let description = "Object \(object.id) - \(object.name)."

        return PageMetadata(title, description: description)
    }
    
    struct FormData: Content {
        
    }
}



