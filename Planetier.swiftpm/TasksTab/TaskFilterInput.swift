import Foundation

struct TaskFilterInput: Hashable, Identifiable, Codable {
    
    var id: Self { self }
    
    enum Deadline: Int, Codable, CaseIterable {
        case pastDeadline = 0
        case inWeek = 7
        case inMonth = 30
    }
    
    var hiddenGroups: Set<String> = []
    var deadline: Deadline?
    var hideDoneTasks = false
}
