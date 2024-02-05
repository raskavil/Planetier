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
    
    convenience init() {
        self.init(id: UUID().uuidString, name: "", state: .todo, subtasks: [], deadline: nil, calendarEventID: nil)
    }
}

struct Subtask: Codable {
    let name: String
    let done: Bool
}
