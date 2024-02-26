import SwiftUI
import SwiftData

// MARK: - View modifier
struct TaskFilterable: ViewModifier {
    
    let isPresented: Binding<Bool>
    let input: TaskFilterInput
    let includeGroupFilter: Bool
    let save: (TaskFilterInput) -> Void
    
    @ViewBuilder func body(content: Content) -> some View {
        TaskFilterView(
            isPresented: isPresented,
            input: input,
            includeGroupFilter: includeGroupFilter,
            save: save,
            superview: { content }
        )
    }
}

extension View {
    
    func taskFilterView(
        isPresented: Binding<Bool>,
        input: TaskFilterInput,
        includeGroupFilter: Bool = true,
        save: @escaping (TaskFilterInput) -> Void
    ) -> some View {
        modifier(TaskFilterable(isPresented: isPresented, input: input, includeGroupFilter: includeGroupFilter, save: save))
    }
}

// MARK: - Task filter view
struct TaskFilterView<Content: View>: View {
    
    @Binding private var isPresented: Bool
    @Query private var groups: [Group]
    @State private var input: TaskFilterInput
    let includeGroupFilter: Bool
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
                            
                            Text("filter")
                                .font(.title)
                                .bold()
                                .padding(.top, .medium)
                            
                            Checkbox(isSelected: $input.hideDoneTasks) {
                                Text("filter.hide_done")
                                    .foregroundStyle(.black)
                                    .bold()
                                Spacer()
                            }
                            
                            HStack(spacing: .zero) {
                                Text("task.edit.deadline")
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

                            if includeGroupFilter {
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
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
    
                    Spacer()
                    
                    LargeButton(title: .init(localized: "save")) {
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
        includeGroupFilter: Bool,
        save: @escaping (TaskFilterInput) -> Void,
        @ViewBuilder superview: () -> Content
    ) {
        self._isPresented = isPresented
        self._input = .init(initialValue: input)
        self.includeGroupFilter = includeGroupFilter
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
            case .pastDeadline: .init(localized: "filter.past_deadline")
            case .inWeek:       .init(localized: "filter.in_week")
            case .inMonth:      .init(localized: "filter.in_month")
            case .none:         .init(localized: "filter.deadline_any")
        }
    }
    
    init(uiText: String) {
        let values = Dictionary(uniqueKeysWithValues: (TaskFilterInput.Deadline.allCases + [nil]).map { ($0.uiText, $0) })
        self = values[uiText].flatMap { $0 }
    }
}
