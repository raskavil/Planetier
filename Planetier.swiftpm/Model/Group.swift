import SwiftData
import Foundation

@Model
class Group {

    @Attribute(.unique) let id: String
    let creationDate: Date
    var name: String
    var planet: String
    @Relationship(deleteRule: .cascade, inverse: \ToDoTask.group) var tasks: [ToDoTask]
    @Transient var appearance: Appearance { .init(rawValue: planet) ?? .mars }
    
    init(
        id: String,
        creationDate: Date,
        name: String,
        planet: String,
        tasks: [ToDoTask]
    ) {
        self.id = id
        self.creationDate = creationDate
        self.name = name
        self.planet = planet
        self.tasks = tasks
    }
}

struct GroupRepresentation: ModelRepresentation {
    
    let id: String?
    let creationDate: Date?
    var name: String
    var planet: String
    var tasks: [ToDoTask]
    
    var representedType: Group {
        .init(
            id: id ?? UUID().uuidString,
            creationDate: creationDate ?? .now,
            name: name,
            planet: planet,
            tasks: tasks
        )
    }
    
    func setValues(on group: Group) {
        group.name = name
        group.planet = planet
        group.tasks = tasks
    }
    
    init(representedType: Group) {
        id = representedType.id
        creationDate = representedType.creationDate
        name = representedType.name
        planet = representedType.planet
        tasks = representedType.tasks
    }
    
    init(
        name: String = "",
        planet: String = "mars",
        tasks: [ToDoTask] = []
    ) {
        id = nil
        creationDate = nil
        self.name = name
        self.planet = planet
        self.tasks = tasks
    }
}
