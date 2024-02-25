import SwiftUI

// MARK: - View modifier
struct GroupEditable: ViewModifier {
    
    let input: Binding<GroupEditView.Input?>
    
    @ViewBuilder func body(content: Content) -> some View {
        GroupEditView(input: input, superview: { content })
    }
}

extension View {
    
    func groupEditView(input: Binding<GroupEditView.Input?>) -> some View {
        modifier(GroupEditable(input: input))
    }
}

// MARK: - Input enum
enum GroupEditViewInput: Equatable, Identifiable {
    case new
    case edit(Group)
    
    var groupRepresentation: GroupRepresentation {
        switch self {
            case .edit(let group):   return .init(representedType: group)
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

struct GroupEditView<Superview: View>: View {
    
    typealias Input = GroupEditViewInput
    
    enum Step: CaseIterable {
        case name, overview
    }
    
    @Namespace var namespace
    @Environment(\.modelContext) var modelContext
    @Binding private var input: GroupEditViewInput?
    @State private var step: Step = .name
    @State private var displayingNameError = false
    @State private var representedGroup: GroupRepresentation?
    private let superview: Superview
    
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
                representedGroup = newValue?.groupRepresentation
                displayingNameError = false
                step = .name
            }
            .sheet(item: $input, content: { task in
                VStack(alignment: .leading, spacing: .zero) {
                    backButton
                    GradientScrollView(contentInsets: .init(vertical: .large)) {
                        VStack(alignment: .leading, spacing: .default) {
                            name
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
        if let representedGroup {
            switch step {
                case .name:
                    Text(.init(localized: "group.edit.name_prompt"))
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    TextField(
                        "group.edit.name_placeholder",
                        text: .init(
                            get: { representedGroup.name },
                            set: { self.representedGroup?.name = $0 }
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
                        Text(.init(localized: "group.edit.name_error"))
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.tint)
                            .padding(.top, -.medium)
                    }
                default:
                    Text(representedGroup.name)
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
        LargeButton(title: step != .overview ? .init(localized: "button.title.next") : .init(localized: "button.title.save")) {
            guard let nextStep else {
                finish()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                guard step != .name || representedGroup?.name.isEmpty != true else {
                    displayingNameError = true
                    return
                }
                displayingNameError = false
                step = nextStep
            }
        }
    }
    
    // MARK: - Finish and init functions
    private func finish() {
        switch (representedGroup, input) {
            case (nil, _), (_, .none):
                break
            case (.some(let representation), .new):
                modelContext.insert(representation.representedType)
            case (.some(let representation), .edit(let group)):
                representation.setValues(on: group)
        }
        representedGroup = nil
        input = nil
    }

    init(input: Binding<Input?>, @ViewBuilder superview: () -> Superview) {
        self._input = input
        self.superview = superview()
    }
}
