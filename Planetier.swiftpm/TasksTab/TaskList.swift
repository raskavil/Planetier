import SwiftUI
import SwiftData

struct TaskList: View {
    
    @Environment(\.modelContext) var context
    @Environment(\.navigation) var navigation
    @Query var tasks: [ToDoTask]
    @Query var groups: [Group]
    
    @State var editedTask: TaskEditViewInput?
    @State var isEditingSort = false
    @State var isEditingFilter = false
    @State var presentedTaskToDelete: ToDoTask?
    @State var isPresentingNewGroupDialog = false
    @State var sorting: TaskSortInput = .userDefaultsValue ?? .init() {
        didSet {
            do { try sorting.saveToUserDefaults() }
            catch { assertionFailure(error.localizedDescription) }
        }
    }
    @State var filter: TaskFilterInput = .userDefaultsValue ?? .init() {
        didSet {
            do { try sorting.saveToUserDefaults() }
            catch { assertionFailure(error.localizedDescription) }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .medium) {
                QueryForEach(sort: sorting.array.map(\.taskSortDescriptor), filter: filter.filterPredicate) { (task: ToDoTask) in
                    TaskCell(
                        task: task,
                        edit: { editedTask = .edit($0) },
                        delete: { presentedTaskToDelete = $0 }
                    )
                    .padding(.horizontal, .default)
                    .transition(.opacity)
                    .clipped()
                }
            }
        }
        .navigationTitle(String(localized: "tab.tasks"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "arrow.up.and.down.text.horizontal") {
                    isEditingSort = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "text.append") {
                    isEditingFilter = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "plus") {
                    guard groups.isEmpty == false else {
                        isPresentingNewGroupDialog = true
                        return
                    }
                    editedTask = .new
                }
            }
        }
        .taskEditView(input: $editedTask)
        .taskSortView(isPresented: $isEditingSort, input: sorting, save: { newValue in withAnimation { sorting = newValue } })
        .taskFilterView(isPresented: $isEditingFilter, input: filter, save: { newValue in withAnimation { filter = newValue }})
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
                    context.delete(presentedTaskToDelete)
                }
            }
        )
        .dialog(
            isPresented: $isPresentingNewGroupDialog,
            title: .init(localized: "task.create_group"),
            text: .init(localized: "task.create_group.text"),
            buttonTitle: .init(localized: "tab.groups"),
            confirmation: {
                isPresentingNewGroupDialog = false
                navigation.performNavigation(to: .createNewGroup)
            }
        )
    }
}

protocol UserDefaultsSingleton: Codable {
    
    static var userDefaultsKey: String { get }
}

extension UserDefaultsSingleton {
    
    static var userDefaultsValue: Self? {
        UserDefaults.standard.data(forKey: userDefaultsKey)
            .flatMap { try? JSONDecoder().decode(Self.self, from: $0) }
    }
    
    func saveToUserDefaults() throws {
        let data = try JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
    }
}

extension TaskSortInput: UserDefaultsSingleton {
    static let userDefaultsKey = "Planetier.TasksTab.TaskSortInput"
}

extension TaskFilterInput: UserDefaultsSingleton {
    static let userDefaultsKey = "Planetier.TasksTab.TaskFilterInput"
}

#Preview {
    NavigationStack {
        TaskList()
    }
}
