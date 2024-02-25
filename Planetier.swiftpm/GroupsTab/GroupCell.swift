import SwiftUI
import SwiftData

struct GroupCell: View {
    
    let group: Group
    let expand: (Group) -> Void
    let delete: (Group) -> Void
    let edit: (Group) -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(height: 100)
            VStack(alignment: .leading, spacing: .medium) {
                GroupNameView(
                    group: group,
                    isExpanded: false,
                    edit: { edit(group) },
                    delete: { delete(group) },
                    namespace: namespace
                )
                GroupPropertiesView(
                    group: group,
                    isExpanded: false,
                    expand: { withAnimation { expand(group) } },
                    namespace: namespace
                )
            }
            .padding(.default)
            .frame(maxWidth: .infinity)
            .background {
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: .defaultRadius, topTrailing: .defaultRadius))
                    .foregroundStyle(.ultraThinMaterial)
            }
        }
        .background(alignment: .top) {
            Image("mars-background")
                .resizable()
                .aspectRatio(0.46, contentMode: .fill)
                .transition(.scale)
                .matchedGeometryEffect(id: GroupsNamespace.groupBackground + group.id, in: namespace)
        }
        .mask(
            RoundedRectangle(cornerRadius: .defaultRadius)
                .matchedGeometryEffect(id: GroupsNamespace.groupMask + group.id, in: namespace)
        )
    }
}

extension Group {
    
    var portionDone: Double {
        guard tasks.count > 0 else { return 0 }
        return Double(tasks.filter { $0.state == .done }.count) / Double(tasks.count)
    }
    
    var percentageText: String {
        .init(localized: "group.\(Int(portionDone*100))percent_done")
    }
}

struct GroupCellPreviews: PreviewProvider {
    
    static let group = Group(
        id: UUID().uuidString,
        creationDate: .now,
        name: "House chores",
        planetName: "YPL-125-Z",
        tasks: []
    )
    
    static var modelContainer: ModelContainer {
        let modelContainer = try! ModelContainer(
            for: Group.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContainer.mainContext.insert(group)
        return modelContainer
    }
    
    static var previews: some View {
        GroupCell(
            group: group,
            expand: { _ in },
            delete: { _ in },
            edit: { _ in },
            namespace: Namespace().wrappedValue
        )
        .modelContainer(modelContainer)
        .padding(.default)
        .previewLayout(.sizeThatFits)
    }
}
