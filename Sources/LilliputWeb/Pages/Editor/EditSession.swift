// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Lilliput

struct EditSession: Codable {
    let id: String
    let title: String
    var groups: [EditGroup]
    
    init(id: String, title: String, groups: [EditGroup] = []) {
        self.id = id
        self.title = title
        self.groups = groups
    }
    
    mutating func add(_ group: EditGroup) {
        groups.append(group)
    }
}

struct EditGroup: Codable {
    let title: String
    let properties: [EditProperty]
    
    init(title: String, properties: [EditProperty] = []) {
        self.title = title
        self.properties = properties
    }
}

struct EditProperty: Codable {
    enum Kind: String, Codable {
        case strings
        case text
    }

    let title: String
    let path: String
    let kind: Kind
    let values: [String]
}

struct EditableObject: Codable {
    let id: String
    let name: String
    
    init(_ object: Object) {
        id = object.id
        name = object.getDefinite()
    }
}
