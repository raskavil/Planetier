import SwiftUI
import SwiftData

// MARK: - View modifier
struct GroupViewModifier: ViewModifier {
    
    let group: Binding<Group?>
    let delete: (Group) -> Void
    let edit: (Group) -> Void
    let editTask: (ToDoTask) -> Void
    let deleteTask: (ToDoTask) -> Void
    let namespace: Namespace.ID
    
    @ViewBuilder func body(content: Content) -> some View {
        GroupView(
            selectedGroup: group,
            delete: delete,
            edit: edit,
            editTask: editTask,
            deleteTask: deleteTask,
            namespace: namespace,
            content: content
        )
    }
}

extension View {
    
    func groupView(
        _ group: Binding<Group?>,
        delete: @escaping (Group) -> Void,
        edit: @escaping (Group) -> Void,
        editTask: @escaping (ToDoTask) -> Void,
        deleteTask: @escaping (ToDoTask) -> Void,
        namespace: Namespace.ID
    ) -> some View {
        modifier(
            GroupViewModifier(
                group: group,
                delete: delete,
                edit: edit,
                editTask: editTask,
                deleteTask: deleteTask,
                namespace: namespace
            )
        )
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
            VStack(alignment: .leading, spacing: .medium) {
                GroupNameView(
                    group: selectedGroup,
                    edit: { edit(selectedGroup) },
                    delete: { delete(selectedGroup) },
                    namespace: namespace
                )
                .padding(.top, 150)
                GroupPropertiesView(
                    group: selectedGroup,
                    expand: { withAnimation { self.selectedGroup = nil } },
                    namespace: namespace
                )
                ForEach(selectedGroup.tasks) { task in
                    TaskCell(task: task, edit: editTask, delete: deleteTask)
                        .transition(.blurReplace)
                }
                Spacer()
            }
            .ignoresSafeArea(.container, edges: .top)
            .padding(.horizontal, .default)
            .background {
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: .defaultRadius, topTrailing: .defaultRadius))
                    .foregroundStyle(.ultraThinMaterial)
                    .padding(.top, 75)
            }
            .background {
                Image("mars-background")
                    .resizable()
                    .aspectRatio(0.46, contentMode: .fill)
                    .transition(.scale)
                    .matchedGeometryEffect(
                        id: GroupsNamespace.groupBackground + selectedGroup.id,
                        in: namespace
                    )
            }
            .mask(
                RoundedRectangle(cornerRadius: .defaultRadius)
                    .ignoresSafeArea(.container, edges: .all)
                    .matchedGeometryEffect(id: GroupsNamespace.groupMask + selectedGroup.id, in: namespace)
            )
        } else {
            content
        }
    }
}
