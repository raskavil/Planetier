import SwiftUI
import SwiftData

struct GroupCell: View {
    
    @State var tasksExpanded = false
    let group: Group
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Image("mars-background")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
                            Button(systemImage: "chevron.down") {
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
        planetName: "YPL-125-Z"
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
        GroupCell(group: group)
            .modelContainer(modelContainer)
            .clipShape(RoundedRectangle(cornerRadius: .defaultRadius))
            .padding(.default)
            .previewLayout(.sizeThatFits)
    }
}
