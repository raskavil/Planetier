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
    
    var filterPredicate: Predicate<ToDoTask> {
        
        func buildConjunction(lhs: some StandardPredicateExpression<Bool>, rhs: some StandardPredicateExpression<Bool>) -> any StandardPredicateExpression<Bool> {
                PredicateExpressions.Conjunction(lhs: lhs, rhs: rhs)
        }
        
        return Predicate<ToDoTask>({ task in
            
            var conditions: [any StandardPredicateExpression<Bool>] = []
            
            let hideExpression = PredicateExpressions.build_Negation(
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
            
            if let deadlineDate = deadline?.deadlineDate {
                let deadlineExpression = PredicateExpressions.build_NilCoalesce(
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
                conditions.append(deadlineExpression)
            }

            
            let hiddenExpression = PredicateExpressions.build_Negation(
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
            
            conditions.append(hideExpression)
            conditions.append(hiddenExpression)
            
            guard let first = conditions.first else {
                return PredicateExpressions.Value(true)
            }

            let closure: (any StandardPredicateExpression<Bool>, any StandardPredicateExpression<Bool>) -> any StandardPredicateExpression<Bool> = {
                buildConjunction(lhs: $0, rhs: $1)
            }

            return conditions.dropFirst().reduce(first, closure)
        })
    }
}

extension TaskFilterInput.Deadline {
    
    var deadlineDate: Date {
        Date(timeIntervalSinceNow: Double(rawValue) * 24.0 * 60.0 * 60.0)
    }
}
