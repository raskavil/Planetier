import SwiftUI
import SwiftData

struct TaskCell: View {
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }
    
    @Environment(\.modelContext) var context
    
    let task: ToDoTask
    let edit: ((ToDoTask) -> Void)?
    let delete: ((ToDoTask) -> Void)?
    @State var isShowingSubtasks = false
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text(task.name).bold()
                Spacer(minLength: 4)
                Menu {
                    Menu("State") {
                        Button("Todo") { withAnimation { task.state = .todo } }
                        Button("In progress") { withAnimation { task.state = .progress } }
                        Button("Done") { withAnimation { task.state = .done } }
                    }
                    if let edit {
                        Button("Edit", systemImage: "square.and.pencil") { edit(task) }
                    }
                    if let delete {
                        Button("Delete", systemImage: "trash") { delete(task) }
                    }
                } label: {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .overlay {
                            Image(systemName: "ellipsis")
                        }
                }
                .frame(width: .large, height: .large)
            }
            HStack(spacing: .small) {
                if task.subtasks.isEmpty == false {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowingSubtasks.toggle()
                        }
                    } label: {
                        Circle()
                            .trim(from: 1 - Double(task.subtasks.filter(\.done).count) / Double(task.subtasks.count), to: 1)
                            .stroke(.tint, lineWidth: .small)
                            .frame(width: .large, height: .large)
                            .rotationEffect(.init(radians: -.pi / 2))
                            .rotation3DEffect(.radians(.pi), axis: (0,1,0))
                            .overlay {
                                Image(systemName: "chevron.up")
                                    .imageScale(.small)
                                    .bold()
                                    .rotationEffect(isShowingSubtasks ? .radians(.pi) : .zero)
                            }
                            .padding(.trailing, 2)
                    }
                }
                task.priority.uiImage
                    .resizable()
                    .frame(width: .large, height: .large)
                    .foregroundStyle(.tint)
                Badge(
                    text: task.state.uiText,
                    style: .init(contentColor: .init(uiColor: .tintColor), borderColor: .init(uiColor: .tintColor))
                )
                if let estimation = task.estimation.map({ Int($0 / 60 / 60) }) {
                    Badge(text: "\(estimation)h")
                        .bold()
                }
                if let deadline = task.deadline {
                    Badge(
                        text: Self.dateFormatter.string(from: deadline),
                        image: .init(systemName: "calendar.badge.clock"),
                        style: .init(
                            contentColor: .white,
                            backgroundColor: .init(uiColor: .tintColor),
                            borderColor: .clear
                        )
                    )
                }
                Spacer()
            }
            if isShowingSubtasks && task.subtasks.isEmpty == false {
                VStack(alignment: .leading, spacing: -1) {
                    ForEach(task.subtasks) { subtask in
                        HStack(alignment: .center, spacing: 0) {
                            Checkbox(
                                isSelected: .init(
                                    get: { subtask.done },
                                    set: { newValue in
                                        guard isShowingSubtasks else { return } // Hiding views triggers Checkmark button action
                                        task.subtasks.firstIndex(of: subtask)
                                            .map { task.subtasks[$0].done = newValue }
                                    }
                                )
                            )
                            .padding(.horizontal, .medium)
                            Text(subtask.name)
                                .padding(.vertical, .medium)
                            Spacer()
                        }
                        .frame(height: .large * 2)
                        .background {
                            RoundedRectangle(cornerRadius: .defaultRadius)
                                .stroke(.black, lineWidth: 1.0)
                                .padding(0.5)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.top, .default)
            }
        }
        .padding(.medium + .small)
        .background {
            RoundedRectangle(cornerRadius: .defaultRadius)
                .foregroundStyle(.white)
                .shadow(radius: 2)
        }
        .padding(2)
    }
}

extension ToDoTask.State {
    
    var uiText: String {
        return switch self {
            case .done:     "Done"
            case .progress: "In progress"
            case .todo:     "Todo"
        }
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: ToDoTask.self, Group.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let group = Group(
        id: "previewGroup",
        creationDate: .now,
        name: "Preview group",
        planetName: "XW21",
        tasks: []
    )
    let task = ToDoTask(
        id: "preview",
        creationDate: .now,
        name: "Preview task",
        state: .progress,
        priority: .medium,
        subtasks: [.init(name: "Random subtask"), .init(name: "Random subtask 2")],
        estimation: nil,
        deadline: nil,
        calendarEventID: nil,
        group: group
    )
    group.tasks.append(task)
    container.mainContext.insert(group)
    return TaskCell(task: task, edit: { _ in }, delete: { _ in })
        .modelContext(.init(container))
}
