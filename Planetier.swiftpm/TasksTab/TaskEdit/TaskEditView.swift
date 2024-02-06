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

    enum Step: CaseIterable {
        case name
        case deadline
        case subtasks
        case overview
        
        var presentationDetent: PresentationDetent {
            switch self {
                case .name, .deadline:      return .fraction(0.5)
                case .subtasks, .overview:  return .medium
            }
        }
    }
    
    @Namespace var namespace

    @Binding var representedTask: ToDoTaskRepresentation?
    @State var step: Step = .name
    
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
                VStack(alignment: .leading, spacing: .default) {
                    backButton
                    ScrollView {
                        content
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    Spacer()
                    nextButton
                }
                .padding(.default)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            })
    }
    
    @ViewBuilder private var content: some View {
        switch step {
            case .name:
                NameView(representedTask: $representedTask, namespace: namespace)
            case .deadline:
                DeadlineView(representedTask: $representedTask, namespace: namespace)
            case .subtasks:
                SubtasksView(representedTask: $representedTask, namespace: namespace)
            case .overview:
                VStack {
                    Text("Overview")
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
            .frame(width: 24, height: 24)
            Spacer()
        }
        .animation(.none, value: representedTask?.id)
    }
    
    private var nextButton: some View {
        Button {
            if let nextStep {
                withAnimation(.easeInOut(duration: 0.3)) { step = nextStep }
            } else {
                submit()
            }
        } label: {
            Text("Next")
                .bold()
                .foregroundStyle(.white)
                .padding(16)
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
