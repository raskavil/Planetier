import SwiftUI
import SwiftData

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
    
    private let superview: Superview
    @Binding private var showingEditView: Bool

    @State var representedTask: ToDoTaskRepresentation
    
    var body: some View {
        superview
            .sheet(isPresented: $showingEditView, content: {
                /* VStack(alignment: .leading, spacing: 16) {
                    content
                    HStack {
                        Button("Left", systemImage: "arrowshape.left.fill") {
                            if let currentIndex = Step.allCases.firstIndex(of: step), Step.allCases.indices.contains(currentIndex - 1) {
                                step = Step.allCases[currentIndex - 1]
                            }
                        }
                        Spacer()
                        Button("Right", systemImage: "arrowshape.right.fill") {
                            if let currentIndex = Step.allCases.firstIndex(of: step), Step.allCases.indices.contains(currentIndex + 1) {
                                step = Step.allCases[currentIndex + 1]
                            }
                        }
                    }
                } */
                NavigationStack {
                    name
                        .padding(16)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            })
    }
    
    private var name: some View {
        VStack {
            TextField("Text", text: $representedTask.name)
            NavigationLink {
                deadline
            } label: {
                Text("Next")
            }
        }
    }
    
    private var deadline: some View {
        VStack {
            DatePicker(
                "Deadline",
                selection: .constant(.now),
                in: PartialRangeThrough(Date.now),
                displayedComponents: [.date]
            )
            NavigationLink {
                subtasks
            } label: {
                Text("Subtasks")
            }
        }
    }
    
    private var subtasks: some View {
        VStack {
            Text("Subtasks")
            NavigationLink {
                
            } label: {
                Text("overview")
            }
        }
    }
    
    private var overview: some View {
        VStack {
            Text("Overview")
        }
    }

    init(
        showingEditView: Binding<Bool>,
        representedTask: ToDoTaskRepresentation,
        @ViewBuilder superview: () -> Superview
    ) {
        self._showingEditView = showingEditView
        self._representedTask = .init(initialValue: representedTask)
        self.superview = superview()
    }
    
}

struct TaskEditViewPreviews: PreviewProvider {
    
    static var previews: some View {
        TaskEditView(
            showingEditView: .constant(true),
            representedTask: .init(name: "Task")
        ) {
            Image(systemName: "list.bullet.clipboard")
        }
    }
}
