import SwiftUI

extension TaskEditView {
    
    struct SubtasksView: View {
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }
        
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
                    if let deadline = representedTask.deadline {
                        HStack {
                            Text("Deadline")
                                .bold()
                            Spacer()
                            Text(dateFormatter.string(from: deadline))
                                .bold()
                        }
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.deadlineViewId,
                            in: namespace
                        )
                    }
                    VStack(alignment: .leading, spacing: -1) {
                        ForEach(Array(representedTask.subtasks.enumerated()), id: \.offset) { index, subtask in
                            TextField(
                                "Subtask",
                                text: .init(
                                    get: { representedTask.subtasks[index].name },
                                    set: { self.representedTask?.subtasks[index].name = $0 }
                                )
                            )
                            .padding(.medium + .small)
                            .background {
                                RoundedRectangle(cornerRadius: .defaultRadius)
                                    .stroke(.gray, lineWidth: 1.0)
                                    .padding(0.5)
                                    .foregroundStyle(.white)
                            }
                        }
                        Button(
                            action: {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    self.representedTask?.subtasks.append(.init(name: "", done: false))
                                }
                            },
                            label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add new subtask")
                                    Spacer()
                                }
                            }
                        )
                        .padding(.medium + .small)
                        .background {
                            RoundedRectangle(cornerRadius: .defaultRadius)
                                .stroke(.gray, lineWidth: 1.0)
                                .padding(0.5)
                                .foregroundStyle(.white)
                        }
                        // .padding(.horizontal, .medium)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    TaskEditView<EmptyView>.SubtasksView(
        representedTask: .constant(.init(name: "Some task", deadline: .now)),
        namespace: Namespace().wrappedValue
    )
}
