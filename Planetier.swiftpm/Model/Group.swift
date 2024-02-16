import SwiftData
import Foundation

@Model
class Group {

    @Attribute(.unique) let id: String
    let creationDate: Date
    var name: String
    var planetName: String
    @Relationship(deleteRule: .cascade, inverse: \ToDoTask.group) var tasks: [ToDoTask]
    
    init(
        id: String,
        creationDate: Date,
        name: String,
        planetName: String,
        tasks: [ToDoTask]
    ) {
        self.id = id
        self.creationDate = creationDate
        self.name = name
        self.planetName = planetName
        self.tasks = tasks
    }
}

struct GroupRepresentation: ModelRepresentation {
    
    let id: String?
    let creationDate: Date?
    var name: String
    var planetName: String
    var tasks: [ToDoTask]
    
    var representedType: Group {
        .init(
            id: id ?? UUID().uuidString,
            creationDate: creationDate ?? .now,
            name: name,
            planetName: planetName,
            tasks: tasks
        )
    }
    
    func setValues(on group: Group) {
        group.name = name
        group.planetName = planetName
        group.tasks = tasks
    }
    
    init(representedType: Group) {
        id = representedType.id
        creationDate = representedType.creationDate
        name = representedType.name
        planetName = representedType.planetName
        tasks = representedType.tasks
    }
    
    init(
        name: String = "",
        planetName: String = "",
        tasks: [ToDoTask] = []
    ) {
        id = nil
        creationDate = nil
        self.name = name
        self.planetName = planetName
        self.tasks = tasks
    }
}
