import Foundation

struct TaskSortInput: Codable, Identifiable, Hashable {
    
    var id: Self {
        self
    }
    
    enum Predicate: CaseIterable, Codable, Hashable, Identifiable {
        case priority, deadline, creation, estimation, name
        
        var id: Self {
            self
        }
    }
    
    var array: [Predicate] = Predicate.allCases {
        didSet {
            if Set(array) != Set(Predicate.allCases) {
                assertionFailure("Array doesn't include all parameters")
            }
        }
    }
}

extension TaskSortInput.Predicate {
    
    var taskSortDescriptor: SortDescriptor<ToDoTask> {
        return switch self {
            case .creation:     .init(\ToDoTask.creationDate)
            case .deadline:     .init(\ToDoTask.deadline)
            case .estimation:   .init(\ToDoTask.estimation)
            case .name:         .init(\ToDoTask.name)
            case .priority:     .init(\ToDoTask.priorityRaw)
        }
    }
}
