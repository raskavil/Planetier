import SwiftUI

extension TaskEditView {
    
    static var deadlineViewId: String {
        "TaskEditViewDeadlineView"
    }
    
    struct DeadlineView: View {
        
        @Binding var representedTask: ToDoTaskRepresentation?
        let namespace: Namespace.ID
        
        var body: some View {
            if let representedTask {
                VStack(alignment: .leading, spacing: .default) {
                    Text(representedTask.name)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                        .font(.title)
                        .bold()
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.nameViewId,
                            in: namespace,
                            anchor: .topLeading
                        )
                    HStack {
                        Text("Does the task have a deadline?")
                            .font(.headline)
                            .bold()
                        Spacer()
                        Checkbox(isSelected: .init(
                            get: { representedTask.deadline != nil },
                            set: { self.representedTask?.deadline = $0 ? .now : nil }
                        ))
                    }
                    if let deadline = representedTask.deadline {
                        DatePicker(
                            "Deadline",
                            selection: .init(
                                get: { deadline },
                                set: { self.representedTask?.deadline = $0 }
                            ),
                            in: PartialRangeFrom(.now),
                            displayedComponents: [.date]
                        )
                        .bold()
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.deadlineViewId,
                            in: namespace
                        )
                    }
                }
            }
        }
    }
}

struct DeadlineViewPreviews: PreviewProvider {
    
    static var date: Date? = .now
    
    static var previews: some View {
        TaskEditView<EmptyView>.DeadlineView(
            representedTask: .constant(.init()),
            namespace: Namespace().wrappedValue
        )
    }
}
