import SwiftUI
import SwiftData

// MARK: - View modifier
struct GroupViewModifier: ViewModifier {
    
    let group: Binding<Group?>
    let namespace: Namespace.ID
    
    @ViewBuilder func body(content: Content) -> some View {
        GroupView(
            selectedGroup: group,
            delete: { _ in },
            edit: { _ in },
            editTask: { _ in },
            deleteTask: { _ in },
            namespace: namespace,
            content: content
        )
    }
}

extension View {
    
    func groupView(_ group: Binding<Group?>, namespace: Namespace.ID) -> some View {
        modifier(GroupViewModifier(group: group, namespace: namespace))
    }
}

struct GroupView<Content: View>: View {
    
    @Binding var selectedGroup: Group?
    let delete: (Group) -> Void
    let edit: (Group) -> Void
    let editTask: (ToDoTask) -> Void
    let deleteTask: (ToDoTask) -> Void
    let namespace: Namespace.ID
    let content: Content
    
    var body: some View {
        if let selectedGroup {
            ZStack(alignment: .top) {
                Color(red: 248.0/256, green: 155.0/256, blue: 93.0/256)
                Image("mars-background")
                    .resizable()
                    .aspectRatio(0.46, contentMode: .fill)
                    .ignoresSafeArea(.container, edges: .top)
                    .transition(.scale)
                    .matchedGeometryEffect(
                        id: GroupsNamespace.groupBackground + selectedGroup.id,
                        in: namespace
                    )
                VStack(alignment: .leading, spacing: .medium) {
                    GroupNameView(
                        group: selectedGroup,
                        edit: { edit(selectedGroup) },
                        delete: { delete(selectedGroup) },
                        namespace: namespace
                    )
                    GroupPropertiesView(
                        group: selectedGroup,
                        expand: { withAnimation { self.selectedGroup = nil } },
                        namespace: namespace
                    )
                    ForEach(selectedGroup.tasks) { task in
                        TaskCell(task: task, edit: editTask, delete: deleteTask)
                    }
                    Spacer()
                }
                .padding(.default)
                .background {
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: .defaultRadius, topTrailing: .defaultRadius))
                        .foregroundStyle(.ultraThinMaterial)
                }
                .padding(.top, 150)
            }
            .mask(
                RoundedRectangle(cornerRadius: .defaultRadius)
                    .matchedGeometryEffect(id: GroupsNamespace.groupMask + selectedGroup.id, in: namespace)
            )
        } else {
            content
        }
    }
}
