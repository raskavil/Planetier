import SwiftUI

extension TaskEditView {
    
    static var nameViewId: String {
        "TaskEditViewNameView"
    }

    struct NameView: View {

        @Binding var representedTask: ToDoTaskRepresentation?
        let namespace: Namespace.ID
        
        var body: some View {
            if let representedTask {
                VStack(alignment: .leading, spacing: .default) {
                    Text("What's the task going to be called?")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    TextField(
                        "Name of the task",
                        text: .init(
                            get: { representedTask.name },
                            set: { self.representedTask?.name = $0 }
                        ),
                        axis: .vertical
                    )
                        .font(.title2)
                        .lineLimit(2)
                        .bold()
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.nameViewId,
                            in: namespace,
                            anchor: .topLeading
                        )
                        .padding(.default)
                        .background {
                            RoundedRectangle(cornerRadius: .defaultRadius)
                                .stroke(.gray, lineWidth: 1)
                                .padding(.horizontal, 0.5)
                                .foregroundStyle(.clear)
                        }
                }
            }
        }
    }
}


#Preview {
    TaskEditView<EmptyView>.NameView(
        representedTask: .constant(.init()),
        namespace: Namespace().wrappedValue
    )
    .padding(.medium)
    .previewLayout(.sizeThatFits)
}
