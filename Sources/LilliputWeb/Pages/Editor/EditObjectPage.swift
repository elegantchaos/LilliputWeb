// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct EditObjectPage: LeafPage {
    let session: EditSession
    
    init(game: GameConfiguration, objectID: String) {
        let driver = BasicDriver()
        let engine = Engine(driver: driver)
        engine.load(url: game.url)
        engine.setup()
        
        let object = engine.object(withID: objectID)
        session = EditSession(for: object)
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title = "Object: \(session.title)"
        let description = "Object \(session.id) - \(session.title)."

        return PageMetadata(title, description: description)
    }
    
    struct FormData: Content {
        
    }
}

extension EditSession {
    init(for object: Object) {
        id = object.id
        title = object.getDefinite()
        groups = [object.definition.generalDescriptionGroup]
    }
}

extension Definition {
    var generalDescriptionGroup: EditGroup {
        var properties: [EditProperty] = []
        for key in generalDescriptionKeys {
            if let alternatives = strings.alternatives(for: key) {
                properties.append(.init(title: key, path: "strings.\(key)", kind: .strings, values: alternatives.strings))
            }
        }

        return EditGroup(title: "Description", properties: properties)
    }
}

