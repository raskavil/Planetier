import SwiftUI
import SwiftData

struct GroupCell: View {
        
    let group: Group
    let delete: (Group) -> Void
    let edit: (Group) -> Void
    @State var tasksExpanded = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Color.orange
                VStack(spacing: 0) {
                    if tasksExpanded == false {
                        Image("mars-background")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    Image("mars-background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 40, alignment: .bottom)
                        .clipped()
                }
                HStack {
                    VStack(alignment: .leading, spacing: .medium) {
                        Text(group.name)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.white)
                        HStack(spacing: .medium) {
                            Button(systemImage: "chevron.up") {
                                withAnimation {
                                    tasksExpanded.toggle()
                                }
                            }
                            .rotationEffect(tasksExpanded ? .radians(.pi) : .radians(.zero))
                            .foregroundStyle(.white)
                            Text(group.planetName)
                                .font(.body)
                                .foregroundStyle(.white)
                            Circle()
                                .trim(from: 0.4, to: 1)
                                .stroke(.white, lineWidth: .small)
                                .frame(width: .large, height: .large)
                                .rotationEffect(.init(radians: -.pi / 2))
                                .rotation3DEffect(.radians(.pi), axis: (0,1,0))
                                .padding(.trailing, 2)
                            Text("85% done")
                                .foregroundStyle(.white)
                        }
                        if tasksExpanded {
                            ForEach(group.tasks) {
                                TaskCell(task: $0, edit: { _ in }, delete: { _ in })
                                    .padding(.medium + .small)
                                    .background {
                                        RoundedRectangle(cornerRadius: .defaultRadius)
                                            .foregroundStyle(.white)
                                            .shadow(radius: 2)
                                    }
                                    .padding(2)
                                    .transition(.opacity)
                                    .clipped()
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.default)
                .frame(maxWidth: .infinity)
                .background {
                    UnevenRoundedRectangle(
                        cornerRadii: .init(topLeading: .defaultRadius, topTrailing: .defaultRadius)
                    )
                    .foregroundStyle(.ultraThinMaterial)
                }
            }
        }
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
        GroupCell(group: group, delete: { _ in }, edit: { _ in })
            .modelContainer(modelContainer)
            .clipShape(RoundedRectangle(cornerRadius: .defaultRadius))
            .padding(.default)
            .previewLayout(.sizeThatFits)
    }
}
