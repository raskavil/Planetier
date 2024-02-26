
struct PlaningInput {
    
    enum Weekday: String, Hashable, CaseIterable {
        case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    }
    
    enum Strategy {
        case priority, balance
    }
    
    var weekdays: Set<Weekday> = []
    var strategy: Strategy = .priority
    var selectedGroups: [Group]
    var hoursPerDay: Double = 0
}
