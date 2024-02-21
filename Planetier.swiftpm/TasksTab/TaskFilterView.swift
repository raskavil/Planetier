import SwiftUI
import SwiftData

// MARK: - View modifier
struct TaskFilterable: ViewModifier {
    
    let isPresented: Binding<Bool>
    let input: TaskFilterInput
    let save: (TaskFilterInput) -> Void
    
    @ViewBuilder func body(content: Content) -> some View {
        TaskFilterView(
            isPresented: isPresented,
            input: input,
            save: save,
            superview: { content }
        )
    }
}

extension View {
    
    func taskFilterView(
        isPresented: Binding<Bool>,
        input: TaskFilterInput,
        save: @escaping (TaskFilterInput) -> Void
    ) -> some View {
        modifier(TaskFilterable(isPresented: isPresented, input: input, save: save))
    }
}

// MARK: - Task filter view
struct TaskFilterView<Content: View>: View {
    
    @Binding private var isPresented: Bool
    @Query private var groups: [Group]
    @State private var input: TaskFilterInput
    private let save: (TaskFilterInput) -> Void
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
                    GradientScrollView(contentInsets: .init(vertical: .default)) {
                        VStack(alignment: .leading, spacing: .default) {
                            
                            Text("Filter")
                                .font(.title)
                                .bold()
                                .padding(.top, .medium)
                            
                            Checkbox(isSelected: $input.hideDoneTasks) {
                                Text("Hide done tasks?")
                                    .foregroundStyle(.black)
                                    .bold()
                                Spacer()
                            }
                            
                            HStack(spacing: .zero) {
                                Text("Deadline")
                                    .bold()
                                Spacer(minLength: .medium)
                                Picker(
                                    selection: .init(get: { input.deadline.uiText }, set: { input.deadline = .init(uiText: $0) }),
                                    content: {
                                        ForEach(TaskFilterInput.Deadline.allCases + [nil], id: \.uiText) { Text($0.uiText) }
                                    },
                                    label: {}
                                )
                                .tint(.black)
                            }

                            Collection(verticalSpacing: .medium) {
                                ForEach(groups) { group in
                                    Badge(
                                        text: group.name,
                                        image: nil,
                                        style: input.hiddenGroups.contains(group.id) ? .init() : .selected
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            if input.hiddenGroups.contains(group.id) {
                                                input.hiddenGroups.remove(group.id)
                                            } else {
                                                input.hiddenGroups.insert(group.id)
                                            }
                                        }
                                    }
                                    .bold()
                                    .fixedSize()
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
    
                    Spacer()
                    
                    LargeButton(title: "Save") {
                        save(input)
                        isPresented = false
                    }
                }
                
                .padding(.default)
                .presentationDetents([.medium])
            }
    }
    
    init(
        isPresented: Binding<Bool>,
        input: TaskFilterInput,
        save: @escaping (TaskFilterInput) -> Void,
        @ViewBuilder superview: () -> Content
    ) {
        self._isPresented = isPresented
        self._input = .init(initialValue: input)
        self.save = save
        self.superview = superview()
    }
}

extension Badge.Style {
    
    static let selected = Self(contentColor: .white, backgroundColor: .init(uiColor: .tintColor), borderColor: .clear)
}

extension Optional<TaskFilterInput.Deadline> {
    
    var uiText: String {
        return switch self {
            case .pastDeadline: "Past the deadline"
            case .inWeek:       "In 7 days"
            case .inMonth:      "In 30 days"
            case .none:         "Any"
        }
    }
    
    init(uiText: String) {
        let values = Dictionary(uniqueKeysWithValues: (TaskFilterInput.Deadline.allCases + [nil]).map { ($0.uiText, $0) })
        self = values[uiText].flatMap { $0 }
    }
}
