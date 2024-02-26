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
    
    private var adjustedTasks: [ToDoTask] {
        guard let selectedGroup else { return [] }
        do {
            return try selectedGroup.tasks
                .filter(filter.filterPredicate(includeGroupsFilter: false))
                .sorted { lhs, rhs in
                    for descriptor in sorting.array.map(\.taskSortDescriptor) {
                        let comparisson = descriptor.compare(lhs, rhs)
                        if comparisson != .orderedSame {
                            return comparisson == .orderedAscending
                        }
                    }
                    return false
                }
        } catch {
            return []
        }
    }
    
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
                HStack(spacing: .medium) {
                    Button(action: { isEditingSort = true }) {
                        Badge(
                            text: .init(localized: "sorting"),
                            image: .init(systemName: "arrow.up.and.down.text.horizontal"),
                            style: .init(contentColor: .white, backgroundColor: .clear, borderColor: .white)
                        )
                    }
                    Button(action: { isEditingFilter = true }) {
                        Badge(
                            text: .init(localized: "filter"),
                            image: .init(systemName: "text.append"),
                            style: .init(contentColor: .white, backgroundColor: .clear, borderColor: .white)
                        )
                    }
                }
                .transition(.opacity)
                ForEach(adjustedTasks) { task in
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
            selectedGroup.appearance.image
                .resizable()
                .aspectRatio(0.46, contentMode: .fill)
                .transition(.scale)
                .padding(.top, -50)
                .matchedGeometryEffect(id: GroupsNamespace.groupBackground + selectedGroup.id, in: namespace)
                .ignoresSafeArea(.container, edges: .top)
        }
        .background { selectedGroup.appearance.color }
        .toolbarBackground(.visible, for: .tabBar)
        .mask(
            RoundedRectangle(cornerRadius: .defaultRadius)
                .ignoresSafeArea(.container, edges: .all)
                .matchedGeometryEffect(id: GroupsNamespace.groupMask + selectedGroup.id, in: namespace)
        )
        .taskEditView(input: $editedTask)
        .taskSortView(isPresented: $isEditingSort, input: sorting, save: { newValue in withAnimation { sorting = newValue } })
        .taskFilterView(
            isPresented: $isEditingFilter,
            input: filter,
            includeGroupFilter: false,
            save: { newValue in withAnimation { filter = newValue }}
        )
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
