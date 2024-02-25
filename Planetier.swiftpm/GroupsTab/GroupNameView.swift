import SwiftUI

struct GroupNameView: View {
    
    let group: Group
    let isExpanded: Bool
    let edit: () -> Void
    let delete: () -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: .zero) {
            Text(group.name)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
            Spacer(minLength: 4)
            Menu {
                Button("task.edit", systemImage: "square.and.pencil", action: edit)
                Button("task.delete", systemImage: "trash", action: delete)
            } label: {
                Rectangle()
                    .foregroundStyle(.clear)
                    .overlay {
                        Image(systemName: "ellipsis")
                    }
            }
            .foregroundStyle(.white)
            .frame(width: .large, height: .large)
        }
        .matchedGeometryEffect(id: GroupsNamespace.groupHeader + group.id, in: namespace)
    }
}
