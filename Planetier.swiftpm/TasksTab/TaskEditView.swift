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
    static var nameViewId: String { "TaskEditViewNameView" }

    enum Step: CaseIterable {
        case name
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
                displayingNameError = false
                step = .name
            }
            .sheet(item: $input, content: { task in
                VStack(alignment: .leading, spacing: .zero) {
                    backButton
                    GradientScrollView(contentInsets: .init(vertical: .large)) {
                        VStack(alignment: .leading, spacing: .default) {
                            name
                            priority
                            deadline
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
                        Text("Name of a task should not be empty.")
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
    
    // MARK: - Priority segment
    @ViewBuilder private var priority: some View {
        switch step {
            case .name:
                EmptyView()
            default:
                if let representedTask {
                    HStack(spacing: .medium) {
                        Text("Priority")
                            .bold()
                        if step == .priority {
                            ForEach(ToDoTask.Priority.allCases, id: \.rawValue) { priority in
                                Button(action: { self.representedTask?.priority = priority }) {
                                    Badge(
                                        text: priority.uiText,
                                        image: priority.uiImage,
                                        style: priority.badgeStyle(for: representedTask.priority)
                                    )
                                    .matchedGeometryEffect(id: "priority_" + priority.rawValue, in: namespace)
                                }
                            }
                        } else {
                            Badge(
                                text: representedTask.priority.uiText,
                                image: representedTask.priority.uiImage,
                                style: representedTask.priority.badgeStyle(for: representedTask.priority)
                            )
                            .matchedGeometryEffect(id: "priority_" + representedTask.priority.rawValue, in: namespace)
                        }
                    }
                }
        }
    }
    
    // MARK: - Deadline segment
    @ViewBuilder private var deadline: some View {
        if let representedTask {
            switch step {
                case .name:
                    EmptyView()
                case .deadline:
                    Checkbox(
                        isSelected: .init(
                            get: { representedTask.deadline != nil },
                            set: { self.representedTask?.deadline = $0 ? .now : nil }
                        ),
                        label: {
                            Text("Does the task have a deadline?")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .bold()
                            Spacer()
                        }
                    )
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
                        .transition(.opacity)
                        .matchedGeometryEffect(
                            id: TaskEditView<Superview>.deadlineViewId,
                            in: namespace
                        )
                    }
                default:
                    if let deadline = representedTask.deadline {
                        HStack {
                            Text("Deadline")
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
                            )
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
                        Button("", systemImage: "trash.fill") {
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
                                Text("Add new subtask")
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
        LargeButton(title: step != .overview ? "Next" : "Save") {
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
                modelContext.insert(representation.representedType)
            case (.some(let representation), .edit(let task)):  
                representation.setValues(on: task)
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
            case .high:     "High"
            case .medium:   "Medium"
            case .low:      "Low"
        }
    }
    
    var uiImage: Image {
        switch self {
            case .high:     .init(systemName: "chevron.up.square.fill")
            case .medium:   .init(systemName: "minus.square.fill")
            case .low:      .init(systemName: "chevron.down.square.fill")
        }
    }
    
    func badgeStyle(for selection: Self) -> Badge.Style {
        .init(
            contentColor: self == selection ? .white : .accentColor,
            backgroundColor: self == selection ? .accentColor : .white,
            borderColor: self == selection ? .clear : .accentColor
        )
    }
    
}

#warning("This might not be necessary")
extension Binding {
    
    func safelyUnwrappedBinding<Parent, Child>(
        of keyPath: WritableKeyPath<Parent, Child>,
        defaultValue: Child
    ) -> Binding<Child> {
        guard let optionalSelf = self as? Binding<Optional<Parent>> else {
            fatalError("Wrong usage of \(#function), \(Parent.self) is not optional.")
        }
        
        return .init {
            optionalSelf.wrappedValue?[keyPath: keyPath] ?? defaultValue
        } set: { newChildValue in
            optionalSelf.wrappedValue?[keyPath: keyPath] = newChildValue
        }

    }
    
    func safelyUnwrappedBinding<Parent, Child>(
        of keyPath: WritableKeyPath<Parent, Optional<Child>>,
        defaultValue: Child
    ) -> Binding<Child> {
        guard let optionalSelf = self as? Binding<Optional<Parent>> else {
            fatalError("Wrong usage of \(#function), \(Parent.self) is not optional.")
        }
        
        return .init {
            optionalSelf.wrappedValue?[keyPath: keyPath] ?? defaultValue
        } set: { newChildValue in
            optionalSelf.wrappedValue?[keyPath: keyPath] = newChildValue
        }
    }
}

extension ModelContainer {
    
    static var previewContainer: ModelContainer {
        try! ModelContainer(for: ToDoTask.self, configurations: .init(isStoredInMemoryOnly: true))
    }
}
