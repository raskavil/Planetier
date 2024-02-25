import SwiftData
import Foundation

@Model
class ToDoTask {

    enum State: String, Codable, Equatable {
        case todo, progress, done
    }
    
    enum Priority: Int, Codable, Comparable, CaseIterable {
        case high, medium, low
        
        static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    @Attribute(.unique) let id: String
    let creationDate: Date
    var name: String
    var stateRaw: State.RawValue
    var priorityRaw: Priority.RawValue
    var subtasks: [Subtask]
    var estimation: TimeInterval?
    var deadline: Date?
    var calendarEventID: String?
    var group: Group?
    var timeSpent: [TimeInterval]

    @Transient var priority: Priority {
        get {
            .init(rawValue: priorityRaw) ?? .medium
        }
        set {
            priorityRaw = newValue.rawValue
        }
    }
    
    @Transient var state: State {
        get {
            .init(rawValue: stateRaw) ?? .todo
        }
        set {
            stateRaw = newValue.rawValue
        }
    }

    init(
        id: String,
        creationDate: Date,
        name: String,
        stateRaw: State.RawValue,
        priorityRaw: Priority.RawValue,
        subtasks: [Subtask],
        estimation: TimeInterval?,
        deadline: Date?,
        calendarEventID: String?,
        group: Group?,
        timeSpent: [TimeInterval]
    ) {
        self.id = id
        self.creationDate = creationDate
        self.name = name
        self.stateRaw = stateRaw
        self.priorityRaw = priorityRaw
        self.subtasks = subtasks
        self.estimation = estimation
        self.deadline = deadline
        self.calendarEventID = calendarEventID
        self.group = group
        self.timeSpent = timeSpent
    }
    
    convenience init(
        id: String,
        creationDate: Date,
        name: String,
        state: State,
        priority: Priority,
        subtasks: [Subtask],
        estimation: TimeInterval?,
        deadline: Date?,
        calendarEventID: String?,
        group: Group?,
        timeSpent: [TimeInterval]
    ) {
        self.init(
            id: id,
            creationDate: creationDate,
            name: name,
            stateRaw: state.rawValue,
            priorityRaw: priority.rawValue,
            subtasks: subtasks,
            estimation: estimation,
            deadline: deadline,
            calendarEventID: calendarEventID,
            group: group,
            timeSpent: timeSpent
        )
    }
}

struct Subtask: Codable, Equatable, Identifiable {
    var id: String
    var name: String
    var done: Bool
    
    init(
        name: String = "",
        done: Bool = false
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.done = done
    }
}

struct ToDoTaskRepresentation: ModelRepresentation, Identifiable, Equatable {

    let id: String?
    let creationDate: Date?
    var name: String
    var state: ToDoTask.State
    var priority: ToDoTask.Priority
    var subtasks: [Subtask]
    var estimation: TimeInterval?
    var deadline: Date?
    var calendarEventID: String?
    var group: Group?
    var timeSpent: [TimeInterval]

    var representedType: ToDoTask {
        .init(
            id: id ?? UUID().uuidString,
            creationDate: creationDate ?? .now,
            name: name,
            state: state,
            priority: priority,
            subtasks: subtasks,
            estimation: estimation,
            deadline: deadline,
            calendarEventID: calendarEventID,
            group: group,
            timeSpent: timeSpent
        )
    }
    
    func setValues(on representedType: ToDoTask) {
        representedType.name = name
        representedType.state = state
        representedType.priority = priority
        representedType.subtasks = subtasks
        representedType.estimation = estimation
        representedType.deadline = deadline
        representedType.calendarEventID = calendarEventID
        representedType.group = group
        representedType.timeSpent = timeSpent
    }

    init(representedType task: ToDoTask) {
        id = task.id
        creationDate = task.creationDate
        name = task.name
        state = task.state
        priority = task.priority
        subtasks = task.subtasks
        estimation = task.estimation
        deadline = task.deadline
        calendarEventID = task.calendarEventID
        group = task.group
        timeSpent = task.timeSpent
    }

    init(
        name: String = "",
        state: ToDoTask.State = .todo,
        priority: ToDoTask.Priority = .medium,
        subtasks: [Subtask] = [],
        estimation: TimeInterval? = nil,
        deadline: Date? = nil,
        calendarEventID: String? = nil,
        group: Group? = nil,
        timeSpent: [TimeInterval] = []
    ) {
        self.id = nil
        self.creationDate = nil
        self.name = name
        self.state = state
        self.priority = priority
        self.subtasks = subtasks
        self.estimation = estimation
        self.deadline = deadline
        self.calendarEventID  = calendarEventID
        self.group = group
        self.timeSpent = timeSpent
    }
}
