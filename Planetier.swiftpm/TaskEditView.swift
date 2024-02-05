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
    
    @State var task: ToDoTask = .init()
    @State var step: Step = .name
    
    var body: some View {
        superview
            .sheet(isPresented: $showingEditView, content: {
                VStack(alignment: .leading, spacing: 16) {
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
                }
                .padding(16)
                .presentationDetents(.init(Step.allCases.map(\.presentationDetent)), selection: .constant(step.presentationDetent))
                .presentationDragIndicator(.visible)
            })
    }
    
    @ViewBuilder var content: some View {
        switch step {
            case .name:
                TextField("Task name", text: .constant("Name"))
            case .deadline:
                DatePicker(
                    "Deadline",
                    selection: .constant(.now),
                    in: PartialRangeThrough(Date.now),
                    displayedComponents: [.date]
                )
            case .subtasks:
                EmptyView()
            case .overview:
                EmptyView()
        }
    }

    init(showingEditView: Binding<Bool>, @ViewBuilder superview: () -> Superview) {
        self._showingEditView = showingEditView
        self.superview = superview()
    }
    
}

struct TaskEditViewPreviews: PreviewProvider {
    
    static var previews: some View {
        let modelContainer = try! ModelContainer(
            for: ToDoTask.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        TaskEditView(showingEditView: .constant(true)) {
            Image(systemName: "list.bullet.clipboard")
        }
        .modelContainer(modelContainer)
    }
}
