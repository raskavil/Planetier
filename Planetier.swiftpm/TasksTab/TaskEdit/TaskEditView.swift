import SwiftUI
import SwiftData

struct TaskEditable: ViewModifier {
    
    let representedTask: Binding<ToDoTaskRepresentation?>
    let submit: () -> Void
    
    @ViewBuilder func body(content: Content) -> some View {
        TaskEditView(
            representedTask: representedTask,
            submit: submit,
            superview: { content }
        )
    }
}

extension View {
    
    func taskEditView(item: Binding<ToDoTaskRepresentation?>, submit: @escaping () -> Void) -> some View {
        modifier(TaskEditable(representedTask: item, submit: submit))
    }
}

struct TaskEditView<Superview: View>: View {
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    static var subtaskIDPrefix: String {
        "TaskEditViewSubtaskView"
    }
    
    static var deadlineViewId: String {
        "TaskEditViewDeadlineView"
    }
    
    static var nameViewId: String {
        "TaskEditViewNameView"
    }

    enum Step: CaseIterable {
        case name
        case deadline
        case subtasks
        case overview
    }
    
    @Namespace var namespace

    @Binding var representedTask: ToDoTaskRepresentation?
    @State var step: Step = .name
    @State var displayingNameError = false
    
    private let superview: Superview
    private let submit: () -> Void
    
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
            .onChange(of: representedTask) { oldValue, newValue in
                if oldValue == nil && newValue != nil {
                    step = .name
                }
            }
            .sheet(item: $representedTask, content: { task in
                VStack(alignment: .leading, spacing: .zero) {
                    backButton
                    ScrollView {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: .default)
                        VStack(alignment: .leading, spacing: .default) {
                            name
                            deadline
                            subtasks
                        }
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: .default)
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    .overlay(alignment: .top) {
                        LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                            .frame(height: .default)
                    }
                    .overlay(alignment: .bottom) {
                        LinearGradient(colors: [.white, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: .default)
                    }
                    nextButton
                }
                .padding(.default)
                .presentationDetents([.medium])
            })
    }
    
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
                        Text("Name of a task should not be empty and should have a maximum of 20 characters")
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
    
    @ViewBuilder private var deadline: some View {
        if let representedTask {
            switch step {
                case .name:
                    EmptyView()
                case .deadline:
                    HStack {
                        Text("Does the task have a deadline?")
                            .font(.headline)
                            .bold()
                        Spacer()
                        Checkbox(isSelected: .init(
                            get: { representedTask.deadline != nil },
                            set: { self.representedTask?.deadline = $0 ? .now : nil }
                        ))
                    }
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
    
    @ViewBuilder private var subtasks: some View {
        if let representedTask, step == .subtasks || step == .overview {
            VStack(alignment: .leading, spacing: -2) {
                ForEach(representedTask.subtasks) { subtask in
                    HStack(spacing: 0) {
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

    private var backButton: some View {
        HStack {
            Button {
                if let previousStep {
                    withAnimation(.easeInOut(duration: 0.3)) { step = previousStep }
                } else {
                    representedTask = nil
                }
            } label: {
                Image(systemName:  previousStep == nil ? "xmark" : "arrow.backward")
                    .foregroundStyle(.black)
                    .bold()
            }
            .frame(width: .large, height: .large)
            Spacer()
        }
        .animation(.none, value: representedTask?.id)
    }
    
    private var nextButton: some View {
        Button {
            if let nextStep {
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
            } else {
                submit()
            }
        } label: {
            Text("Next")
                .bold()
                .foregroundStyle(.white)
                .padding(.default)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: .defaultRadius)
                        .foregroundStyle(.blue)
                }
        }
    }

    init(
        representedTask: Binding<ToDoTaskRepresentation?>,
        submit: @escaping () -> Void,
        @ViewBuilder superview: () -> Superview
    ) {
        self._representedTask = representedTask
        self.submit = submit
        self.superview = superview()
    }
    
}

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

struct TaskEditViewPreviews: PreviewProvider {
    
    static var previews: some View {
        TaskEditView(
            representedTask: .constant(.init(name: "Task")),
            submit: {}
        ) {
            Image(systemName: "list.bullet.clipboard")
        }
    }
    
}
