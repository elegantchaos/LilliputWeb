// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Lilliput
import Vapor

struct EditObjectPage: LeafPage {
    let session: EditSession
    
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
                let path = "strings.\(key)"
                let title = label(forPath: path)
                let kind: EditProperty.Kind = pathIsMultiline(path) ? .text : .strings
                properties.append(.init(title: title, path: path, kind: kind, values: alternatives.strings))
            }
        }

        return EditGroup(title: "Description", properties: properties)
    }
    
    func update(fromEditSubmission properties: [String:String]) {
        for (key, value) in properties {
            print("\(key): \(value)")
        }
    }
}

