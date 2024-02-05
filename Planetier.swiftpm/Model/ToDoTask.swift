import SwiftData
import Foundation

@Model
class ToDoTask {
    
    enum State: String, Codable {
        case todo, progress, done
    }
    
    let id: String
    var name: String
    var state: State
    var subtasks: [Subtask]
    var deadline: Date?
    var calendarEventID: String?
    
    init(
        id: String,
        name: String,
        state: State,
        subtasks: [Subtask],
        deadline: Date?,
        calendarEventID: String?
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.subtasks = subtasks
        self.deadline = deadline
        self.calendarEventID = calendarEventID
    }
}

struct Subtask: Codable {
    let name: String
    let done: Bool
}

struct ToDoTaskRepresentation: ModelRepresentation {
    
    let id: String?
    var name: String
    var state: ToDoTask.State
    var subtasks: [Subtask]
    var deadline: Date?
    var calendarEventID: String?
    
    var representedType: ToDoTask {
        .init(
            id: id ?? UUID().uuidString,
            name: name,
            state: state,
            subtasks: subtasks,
            deadline: deadline,
            calendarEventID: calendarEventID
        )
    }
    
    init(representedType task: ToDoTask) {
        id = task.id
        name = task.name
        state = task.state
        subtasks = task.subtasks
        deadline = task.deadline
        calendarEventID = task.calendarEventID
    }
    
    init(
        name: String = "",
        state: ToDoTask.State = .todo,
        subtasks: [Subtask] = [],
        deadline: Date? = nil,
        calendarEventID: String? = nil
    ) {
        self.id = nil
        self.name = name
        self.state = state
        self.subtasks = subtasks
        self.deadline = deadline
        self.calendarEventID  = calendarEventID
    }
}
