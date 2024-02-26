import Foundation

struct TaskFilterInput: Hashable, Identifiable, Codable {
    
    var id: Self { self }
    
    enum Deadline: Double, Codable, CaseIterable {
        case pastDeadline = 0
        case inWeek = 7
        case inMonth = 30
    }
    
    var hiddenGroups: Set<String> = []
    var deadline: Deadline?
    var hideDoneTasks = false
    
    func filterPredicate(includeGroupsFilter: Bool = true) -> Predicate<ToDoTask> {
        
        typealias Condition = StandardPredicateExpression<Bool>
        
        func conjunction(lhs: some Condition, rhs: some Condition) -> any Condition {
            PredicateExpressions.Conjunction(lhs: lhs, rhs: rhs)
        }
        
        return Predicate<ToDoTask>({ task in
            
            var conditions: [any Condition] = []
            
            conditions.append(
                PredicateExpressions.build_Negation(
                    PredicateExpressions.build_Conjunction(
                        lhs: PredicateExpressions.build_Arg(hideDoneTasks),
                        rhs: PredicateExpressions.build_Equal(
                            lhs: PredicateExpressions.build_KeyPath(
                                root: PredicateExpressions.build_Arg(task),
                                keyPath: \.stateRaw
                            ),
                            rhs: PredicateExpressions.Value(ToDoTask.State.done.rawValue)
                        )
                    )
                )
            )
            
            if let deadlineDate = deadline?.deadlineDate {
                conditions.append(
                    PredicateExpressions.build_NilCoalesce(
                        lhs: PredicateExpressions.build_flatMap(
                            PredicateExpressions.build_KeyPath(root: task, keyPath: \.deadline), { deadline in
                                PredicateExpressions.build_Comparison(
                                    lhs: PredicateExpressions.build_Arg(deadlineDate),
                                    rhs: deadline,
                                    op: .greaterThanOrEqual
                                )
                            }
                        ),
                        rhs: PredicateExpressions.Value(false)
                    )
                )
            }

            if includeGroupsFilter {
                conditions.append(
                    PredicateExpressions.build_Negation(
                        PredicateExpressions.build_NilCoalesce(
                            lhs: PredicateExpressions.build_flatMap(
                                PredicateExpressions.build_KeyPath(
                                    root: PredicateExpressions.build_Arg(task),
                                    keyPath: \.group
                                )
                            ) {
                                PredicateExpressions.build_contains(
                                    PredicateExpressions.build_Arg(hiddenGroups),
                                    PredicateExpressions.build_KeyPath(
                                        root: PredicateExpressions.build_Arg($0),
                                        keyPath: \.id
                                    )
                                )
                            },
                            rhs: PredicateExpressions.Value(false)
                        )
                    )
                )
            }
            
            let conjunction: (any Condition, any Condition) -> any Condition = { conjunction(lhs: $0, rhs: $1) }
            return conditions.first.map { conditions.dropFirst().reduce($0, conjunction)  } ?? PredicateExpressions.Value(true)
        })
    }
}

extension TaskFilterInput.Deadline {
    
    var deadlineDate: Date {
        Date(timeIntervalSinceNow: Double(rawValue) * 24.0 * 60.0 * 60.0)
    }
}
