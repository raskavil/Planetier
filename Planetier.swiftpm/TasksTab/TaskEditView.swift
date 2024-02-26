import SwiftUI
import SwiftData

// MARK: - View modifier
struct TaskEditable: ViewModifier {
    
    let input: Binding<TaskEditView.Input?>
    
    @ViewBuilder func body(content: Content) -> some View {
        TaskEditView(
            input: input,
            superview: { content }
        )
    }
}

extension View {
    
    func taskEditView(input: Binding<TaskEditView.Input?>) -> some View {
        modifier(TaskEditable(input: input))
    }
}

// MARK: - Input enum
enum TaskEditViewInput: Equatable, Identifiable {
    case new
    case edit(ToDoTask)
    
    var taskRepresentation: ToDoTaskRepresentation {
        switch self {
            case .edit(let task):   return .init(representedType: task)
            case .new:              return .init()
        }
    }
    
    var id: String {
        switch self {
            case .edit(let task):   return task.id
            case .new:              return "new_task"
        }
    }
}

// MARK: - View definition
struct TaskEditView<Superview: View>: View {
    
    typealias Input = TaskEditViewInput
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    static var subtaskIDPrefix: String { "TaskEditViewSubtaskView" }
    static var deadlineViewId: String { "TaskEditViewDeadlineView" }
    static var estimationViewId: String { "TaskEditViewEstimationView" }
    static var nameViewId: String { "TaskEditViewNameView" }

    enum Step: CaseIterable {
        case name
        case group
        case priority
        case deadline
        case estimation
        case subtasks
        case overview
    }
    
    @Namespace private var namespace
    @Environment(\.modelContext) private var modelContext
    
    @Binding private var input: Input?
    private let superview: Superview

    @Query private var groups: [Group]
    @State private var representedTask: ToDoTaskRepresentation?
    @State private var step: Step = .name
    @State private var displayingNameError = false
    
    var nextStep: Step? {
        if let currentIndex = Step.allCases.firstIndex(of: step), Step.allCases.indices.contains(currentIndex + 1) {
            return Step.allCases[currentIndex + 1]
        } else {
            return nil
        }
    }
    
    var previousStep: Step? {
        if let currentIndex = Step.allCases.firstIndex(of: step), Step.allCases.indices.contains(currentIndex - 1) {
            return Step.allCases[currentIndex - 1]
        } else {
            return nil
        }
    }
    
    var body: some View {
        superview
            .onChange(of: input) { _, newValue in
                representedTask = newValue?.taskRepresentation
                if representedTask?.group == nil {
                    representedTask?.group = groups.first
                }
                displayingNameError = false
                step = .name
            }
            .sheet(item: $input, content: { task in
                VStack(alignment: .leading, spacing: .zero) {
                    backButton
                    GradientScrollView(contentInsets: .init(vertical: .large)) {
                        VStack(alignment: .leading, spacing: .default) {
                            name
                            group
                            priority
                            deadline
                            estimation
                            subtasks
                        }
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    nextButton
                }
                .padding(.default)
                .presentationDetents([.medium])
            })
    }
    
    // MARK: - Name segment
    @ViewBuilder private var name: some View {
        if let representedTask {
            switch step {
                case .name:
                    Text(.init(localized: "task.edit.name_prompt"))
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    TextField(
                        "task.edit.name_placeholder",
                        text: .init(
                            get: { representedTask.name },
                            set: { self.representedTask?.name = $0 }
                        ),
                        axis: .vertical
                    )
                    .font(.headline)
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
                    if displayingNameError {
                        Text(.init(localized: "task.edit.name_error"))
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.tint)
                            .padding(.top, -.medium)
                    }
                default:
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
            }
        }
    }
    
    // MARK: - Group segment
    
    private var groupBinding: Binding<String> {
        .init(
            get: { representedTask?.group?.id ?? groups.first?.id ?? "" },
            set: { selectedId in representedTask?.group = groups.first(where: { $0.id == selectedId }) }
        )
    }
    
    @ViewBuilder private var group: some View {
        switch step {
            case .name:
                EmptyView()
            case .group:
                HStack(spacing: .medium) {
                    Text("task.edit.group")
                        .bold()
                    Spacer()
                    Picker(
                        "task.edit.group",
                        selection: groupBinding,
                        content: {
                            ForEach(groups, id: \.id) { group in
                                Text(group.name)
                                    .foregroundStyle(group.appearance.color)
                            }
                        }
                    )
                    .bold()
                    .foregroundStyle(.black)
                    .matchedGeometryEffect(id: "TaskEditGroupView", in: namespace)
                    .pickerStyle(.menu)
                }
                .transition(.opacity)
            default:
                HStack {
                    Text("task.edit.group")
                        .bold()
                    Spacer()
                    Text(representedTask?.group?.name ?? "")
                        .foregroundStyle(representedTask?.group?.appearance.color ?? .accentColor)
                        .matchedGeometryEffect(id: "TaskEditGroupView", in: namespace)
                }
        }
    }
    
    // MARK: - Priority segment
    @ViewBuilder private var priority: some View {
        switch step {
            case .name, .group:
                EmptyView()
            default:
                if let representedTask {
                    HStack(spacing: .medium) {
                        Text(.init(localized: "task.priority"))
                            .bold()
                        if step == .priority {
                            ForEach(ToDoTask.Priority.allCases, id: \.rawValue) { priority in
                                Button(action: { self.representedTask?.priority = priority }) {
                                    Badge(
                                        text: priority.uiText,
                                        image: priority.uiImage,
                                        style: priority.badgeStyle(
                                            for: representedTask.priority,
                                            color: representedTask.group?.appearance.color ?? .accentColor
                                        )
                                    )
                                    .matchedGeometryEffect(id: "priority_\(priority.rawValue)", in: namespace)
                                }
                            }
                        } else {
                            Spacer()
                            Badge(
                                text: representedTask.priority.uiText,
                                image: representedTask.priority.uiImage,
                                style: representedTask.priority.badgeStyle(
                                    for: representedTask.priority,
                                    color: representedTask.group?.appearance.color ?? .accentColor
                                )
                            )
                            .matchedGeometryEffect(id: "priority_\(representedTask.priority.rawValue)", in: namespace)
                        }
                    }
                    .transition(.opacity)
                }
        }
    }
    
    // MARK: - Deadline segment
    @ViewBuilder private var deadline: some View {
        if let representedTask {
            switch step {
                case .name, .group, .priority:
                    EmptyView()
                case .deadline:
                    Checkbox(
                        isSelected: .init(
                            get: { representedTask.deadline != nil },
                            set: { self.representedTask?.deadline = $0 ? .now : nil }
                        ),
                        color: representedTask.group?.appearance.color ?? .accentColor,
                        label: {
                            Text(.init(localized: "task.edit.deadline_prompt"))
                                .font(.headline)
                                .foregroundStyle(.black)
                                .bold()
                            Spacer()
                        }
                    )
                    if let deadline = representedTask.deadline {
                        DatePicker(
                            "task.edit.deadline",
                            selection: .init(
                                get: { deadline },
                                set: { self.representedTask?.deadline = $0 }
                            ),
                            displayedComponents: [.date]
                        )
                        .bold()
                        .transition(.opacity)
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.deadlineViewId,
                            in: namespace
                        )
                    }
                default:
                    if let deadline = representedTask.deadline {
                        HStack {
                            Text(.init(localized: "task.edit.deadline"))
                                .bold()
                            Spacer()
                            Text(Self.dateFormatter.string(from: deadline))
                                .bold()
                        }
                        .transition(.opacity)
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.deadlineViewId,
                            in: namespace
                        )
                    }
            }
        }
    }
    
    // MARK: - Estimation segment
    @ViewBuilder private var estimation: some View {
        if let representedTask {
            switch step {
            case .name, .group, .priority, .deadline:
                    EmptyView()
                case .estimation:
                    Checkbox(
                        isSelected: .init(
                            get: { representedTask.estimation != nil },
                            set: { self.representedTask?.estimation = $0 ? 0 : nil }
                        ),
                        color: representedTask.group?.appearance.color ?? .accentColor,
                        label: {
                            Text(.init(localized: "task.edit.add_estimation"))
                                .font(.headline)
                                .foregroundStyle(.black)
                                .bold()
                            Spacer()
                        }
                    )
                    if let estimation = representedTask.estimation {
                        Picker(
                            "task.edit.estimation",
                            selection: .init(
                                get: { Int(estimation / 60 / 60) },
                                set: { self.representedTask?.estimation = Double($0) * 60 * 60 }
                            ),
                            content: {
                                ForEach([0,1,2,3,4,5,6,12,18,24,36,48], id: \.self) {
                                    Text($0.estimationText)
                                        .bold()
                                }
                            }
                        )
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.estimationViewId,
                            in: namespace
                        )
                        .pickerStyle(WheelPickerStyle())
                        .transition(.opacity)
                        .frame(height: .large * 3)
                        .bold()
                        .transition(.opacity)
                    }
                default:
                    if let estimation = representedTask.estimation.map({ Int($0 / 60 / 60) }) {
                        HStack(spacing: .small) {
                            Text(.init(localized: "task.edit.estimation"))
                                .bold()
                            Spacer()
                            Text(estimation.estimationText)
                                .bold()
                                .matchedGeometryEffect(
                                    id: TaskEditView<Superview>.estimationViewId,
                                    in: namespace
                                )
                        }
                    }
            }
        }
    }
    
    // MARK: - Subtasks segment
    @ViewBuilder private var subtasks: some View {
        if let representedTask, step == .subtasks || step == .overview {
            VStack(alignment: .leading, spacing: -2) {
                ForEach(representedTask.subtasks) { subtask in
                    HStack(alignment: .center, spacing: 0) {
                        Checkbox(
                            isSelected: .init(
                                get: { subtask.done },
                                set: { newValue in
                                    self.representedTask?.subtasks.firstIndex(of: subtask)
                                        .map { self.representedTask?.subtasks[$0].done = newValue }
                                }
                            ),
                            color: representedTask.group?.appearance.color ?? .accentColor
                        )
                        .padding(.horizontal, .medium)
                        if step == .subtasks {
                            TextField(
                                "",
                                text: .init(
                                    get: { subtask.name },
                                    set: { newName in
                                        self.representedTask?.subtasks.firstIndex(of: subtask)
                                            .map { self.representedTask?.subtasks[$0].name = newName }
                                    }
                                )
                            )
                            .padding(.vertical, .medium)
                        } else {
                            Text(subtask.name)
                                .padding(.vertical, .medium)
                            Spacer()
                        }
                        Button(systemImage: "trash.fill") {
                            withAnimation(.easeIn(duration: 0.2)) {
                                self.representedTask?.subtasks.firstIndex(of: subtask)
                                    .map { self.representedTask?.subtasks.remove(atOffsets: [$0]) }
                            }
                        }
                        .opacity(step == .subtasks ? 1 : 0)
                        .disabled(step == .overview)
                        .padding(.horizontal, .medium)
                    }
                    .bold()
                    .frame(height: .large * 2)
                    .background {
                        RoundedRectangle(cornerRadius: .defaultRadius)
                            .stroke(.black, lineWidth: 2.0)
                            .padding(1.0)
                            .foregroundStyle(.white)
                    }
                    .transition(.opacity)
                    .matchedGeometryEffect(
                        id: TaskEditView<Superview>.subtaskIDPrefix + subtask.id,
                        in: namespace
                    )
                }
                if step == .subtasks {
                    Button(
                        action: {
                            withAnimation(.easeIn(duration: 0.2)) {
                                self.representedTask?.subtasks.append(.init(name: "", done: false))
                            }
                        },
                        label: {
                            HStack(spacing: .medium) {
                                Image(systemName: "plus")
                                Text(.init(localized: "task.edit.subtask_new"))
                                Spacer()
                            }
                            .bold()
                        }
                    )
                    .padding(.medium)
                    .frame(height: .large * 2)
                    .background {
                        RoundedRectangle(cornerRadius: .defaultRadius)
                            .stroke(.black, lineWidth: 2.0)
                            .padding(1.0)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    // MARK: - Buttons
    private var backButton: some View {
        HStack {
            Button {
                if let previousStep {
                    withAnimation(.easeInOut(duration: 0.3)) { step = previousStep }
                } else {
                    input = nil
                }
            } label: {
                Image(systemName:  previousStep == nil ? "xmark" : "arrow.backward")
                    .foregroundStyle(.black)
                    .bold()
            }
            .frame(width: .large, height: .large)
            Spacer()
        }
        .animation(.none, value: step)
    }
    
    private var nextButton: some View {
        LargeButton(
            title: step != .overview 
            ? .init(localized: "button.title.next")
            : .init(localized: "button.title.save")
        ) {
            guard let nextStep else {
                finish()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                guard step != .name || representedTask?.name.isEmpty != true else {
                    displayingNameError = true
                    return
                }
                displayingNameError = false
                
                if representedTask?.estimation == 0 {
                    representedTask?.estimation = nil
                }
                
                if let subtasks = representedTask?.subtasks {
                    representedTask?.subtasks = subtasks.filter { $0.name.isEmpty == false }
                }
                step = nextStep
            }
        }
    }
    
    // MARK: - Finish and init functions
    private func finish() {
        switch (representedTask, input) {
            case (nil, _), (_, .none):
                break
            case (.some(let representation), .new):
                withAnimation {
                    let task = representation.representedType
                    modelContext.insert(task)
                    representation.group?.tasks.append(task)
                }
            case (.some(let representation), .edit(let task)):
                withAnimation {
                    if task.group != representation.group {
                        _ = task.group?.tasks.firstIndex(of: task).map { task.group?.tasks.remove(at: $0) }
                        representation.group?.tasks.append(task)
                    }
                    representation.setValues(on: task)
                }
        }
        representedTask = nil
        input = nil
    }

    init(input: Binding<Input?>, @ViewBuilder superview: () -> Superview) {
        self._input = input
        self.superview = superview()
    }
    
}

extension ToDoTask.Priority {
    
    var uiText: String {
        switch self {
            case .high:     .init(localized: "task.priority.high")
            case .medium:   .init(localized: "task.priority.medium")
            case .low:      .init(localized: "task.priority.low")
        }
    }
    
    var uiImage: Image {
        switch self {
            case .high:     .init(systemName: "chevron.up.square.fill")
            case .medium:   .init(systemName: "minus.square.fill")
            case .low:      .init(systemName: "chevron.down.square.fill")
        }
    }
    
    func badgeStyle(for selection: Self, color: Color) -> Badge.Style {
        .init(
            contentColor: self == selection ? .white : color,
            backgroundColor: self == selection ? color : .white,
            borderColor: color
        )
    }
    
}

extension Int {

    var estimationText: String {
        .init(localized: "task.edit.estimation_\(self)hours")
    }
}
