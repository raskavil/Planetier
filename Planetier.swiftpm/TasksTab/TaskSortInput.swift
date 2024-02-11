
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
    
    var useGroups = false
}

extension TaskSortInput.Predicate {
    
    var predicate: (ToDoTask, ToDoTask) -> Bool {
        switch self {
            case .creation:     return { $0.creationDate > $1.creationDate }
            case .deadline:     return { lhs, rhs in
                guard let lhsDeadline = lhs.deadline else { return false }
                guard let rhsDeadline = rhs.deadline else { return true }
                return lhsDeadline > rhsDeadline
            }
            case .estimation:   return { lhs, rhs in
                guard let lhsEstimation = lhs.estimation else { return false }
                guard let rhsEstimation = rhs.estimation else { return true }
                return lhsEstimation > rhsEstimation
            }
            case .priority:     return { $0.priority > $1.priority }
            case .name:         return { $0.name > $1.name }
        }
    }
}

extension [ToDoTask] {
    
    func sorted(using input: TaskSortInput) -> Self {
        sorted { lhs, rhs in
            let predicates = input.array.map(\.predicate)
            for predicate in predicates {
                guard predicate(lhs, rhs) == predicate(lhs, rhs) else { continue }
                return predicate(lhs, rhs)
            }
            return false
        }
    }
}
