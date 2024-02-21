import SwiftUI

// MARK: - View modifier
struct TaskSortable: ViewModifier {
    
    let isPresented: Binding<Bool>
    let input: TaskSortInput
    let save: (TaskSortInput) -> Void
    
    @ViewBuilder func body(content: Content) -> some View {
        TaskSortView(
            isPresented: isPresented,
            input: input,
            save: save,
            superview: { content }
        )
    }
}

extension View {
    
    func taskSortView(
        isPresented: Binding<Bool>,
        input: TaskSortInput,
        save: @escaping (TaskSortInput) -> Void
    ) -> some View {
        modifier(TaskSortable(isPresented: isPresented, input: input, save: save))
    }
}

// MARK: - Task sort view
struct TaskSortView<Content: View>: View {
    
    @Binding private var isPresented: Bool
    @State private var input: TaskSortInput
    private let save: (TaskSortInput) -> Void
    private let superview: Content
    
    var body: some View {
        superview
            .sheet(isPresented: $isPresented) {
                VStack(alignment: .leading, spacing: .zero) {
                    HStack {
                        Button { isPresented = false } label: {
                            Image(systemName:  "xmark")
                                .foregroundStyle(.black)
                                .bold()
                        }
                        .frame(width: .large, height: .large)
                        Spacer()
                    }
                    
                    Text("Sorting priority")
                        .font(.title)
                        .bold()
                        .padding(.top, .large)
                        .padding(.bottom, .default)
                    
                    List($input.array, editActions: .move) { value in
                        HStack {
                            Image(systemName: "mount.fill")
                            Text(value.wrappedValue.uiText)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal, .default)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init())
                    }
                    .padding(.horizontal, -.default)
                    .listStyle(.plain)
                    .scrollBounceBehavior(.basedOnSize)
                    
                    Spacer(minLength: 0)
                    
                    LargeButton(title: "Save") {
                        save(input)
                        isPresented = false
                    }
                    .padding(.top, .default)
                }
                .padding(.default)
                .presentationDetents([.medium])
            }
    }
    
    init(
        isPresented: Binding<Bool>,
        input: TaskSortInput,
        save: @escaping (TaskSortInput) -> Void,
        @ViewBuilder superview: () -> Content
    ) {
        self._isPresented = isPresented
        self._input = .init(initialValue: input)
        self.save = save
        self.superview = superview()
    }
}

extension TaskSortInput.Predicate {
    
    var uiText: String {
        return switch self {
            case .creation:     "Creation"
            case .deadline:     "Deadline"
            case .estimation:   "Estimation"
            case .priority:     "Priority"
            case .name:         "Name"
        }
    }
}
