import SwiftUI
import SwiftData

// MARK: - View modifier
struct GroupViewModifier: ViewModifier {
    
    let group: Binding<Group?>
    let delete: (Group) -> Void
    let edit: (Group) -> Void
    let namespace: Namespace.ID
    
    @ViewBuilder func body(content: Content) -> some View {
        GroupView(
            selectedGroup: group,
            delete: delete,
            edit: edit,
            namespace: namespace,
            superview: content
        )
    }
}

extension View {
    
    func groupView(
        _ group: Binding<Group?>,
        delete: @escaping (Group) -> Void,
        edit: @escaping (Group) -> Void,
        namespace: Namespace.ID
    ) -> some View {
        modifier(
            GroupViewModifier(
                group: group,
                delete: delete,
                edit: edit,
                namespace: namespace
            )
        )
    }
}

struct GroupView<Superview: View>: View {
    
    @Environment(\.modelContext) var modelContext
    @Binding var selectedGroup: Group?
    
    @State var editedTask: TaskEditViewInput?
    @State var presentedTaskToDelete: ToDoTask?
    
    @State var isEditingSort = false
    @State var sorting: TaskSortInput = .userDefaultsValue ?? .init() {
        didSet {
            do { try sorting.saveToUserDefaults() }
            catch { assertionFailure(error.localizedDescription) }
        }
    }
    
    @State var isEditingFilter = false
    @State var filter: TaskFilterInput = .userDefaultsValue ?? .init() {
        didSet {
            do { try sorting.saveToUserDefaults() }
            catch { assertionFailure(error.localizedDescription) }
        }
    }

    let delete: (Group) -> Void
    let edit: (Group) -> Void
    let namespace: Namespace.ID
    let superview: Superview
    
    var body: some View {
        if let selectedGroup {
            content(selectedGroup)
        } else {
            superview
        }
    }
    
    private func content(_ selectedGroup: Group) -> some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: .medium) {
                GroupNameView(
                    group: selectedGroup,
                    isExpanded: true,
                    edit: { edit(selectedGroup) },
                    delete: { delete(selectedGroup) },
                    namespace: namespace
                )
                .padding(.top, .default)
                GroupPropertiesView(
                    group: selectedGroup,
                    isExpanded: true,
                    expand: { withAnimation { self.selectedGroup = nil } },
                    namespace: namespace
                )
                ForEach(selectedGroup.tasks) { task in //(selectedGroup.tasks.filter({ $0.state != .done})) { task in
                    TaskCell(
                        task: task,
                        edit: { task in withAnimation { editedTask = .edit(task) } },
                        delete: { task in withAnimation { presentedTaskToDelete = task } }
                    )
                    .transition(.blurReplace)
                }
                Spacer()
            }
        }
        .padding(.top, 60)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .padding(.horizontal, .default)
        .background {
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: .defaultRadius, topTrailing: .defaultRadius))
                .foregroundStyle(.ultraThinMaterial)
                .padding(.top, 60)
        }
        .background(alignment: .top) {
            Image("mars-background")
                .resizable()
                .aspectRatio(0.46, contentMode: .fill)
                .transition(.scale)
                .matchedGeometryEffect(id: GroupsNamespace.groupBackground + selectedGroup.id, in: namespace)
                .ignoresSafeArea(.container, edges: .top)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .mask(
            RoundedRectangle(cornerRadius: .defaultRadius)
                .ignoresSafeArea(.container, edges: .all)
                .matchedGeometryEffect(id: GroupsNamespace.groupMask + selectedGroup.id, in: namespace)
        )
        .taskEditView(input: $editedTask)
        .taskSortView(isPresented: $isEditingSort, input: sorting, save: { newValue in withAnimation { sorting = newValue } })
        .dialog(
            isPresented: .init(
                get: { presentedTaskToDelete != nil },
                set: { presentedTaskToDelete = $0 ? presentedTaskToDelete : nil }
            ),
            accessoryView: Image("delete", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150),
            title: .init(localized: "task.delete"),
            text: .init(localized: "task.delete.confirmation"),
            buttonTitle: .init(localized: "task.delete"),
            buttonStyle: .init(backgroundColor: .red),
            confirmation: {
                if let presentedTaskToDelete {
                    self.presentedTaskToDelete = nil
                    modelContext.delete(presentedTaskToDelete)
                }
            }
        )
    }
}
