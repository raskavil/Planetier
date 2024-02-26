import SwiftUI

struct GroupPropertiesView: View {
    
    let group: Group
    let isExpanded: Bool
    let expand: () -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: .medium) {
            Button(systemImage: "chevron.down", action: expand)
                .rotationEffect(isExpanded ? .zero : .radians(.pi))
                .foregroundStyle(.white)
                .frame(width: .large, height: .large)
                .matchedGeometryEffect(id: GroupsNamespace.groupChevron + group.id, in: namespace)
            if group.portionDone > 0 {
                HStack(spacing: .medium) {
                    Circle()
                        .trim(from: 1 - group.portionDone, to: 1)
                        .stroke(.white, lineWidth: .small)
                        .frame(width: .large, height: .large)
                        .rotationEffect(.init(radians: -.pi / 2))
                        .rotation3DEffect(.radians(.pi), axis: (0,1,0))
                        .padding(.trailing, 2)
                    Text(group.percentageText)
                        .foregroundStyle(.white)
                }
                .matchedGeometryEffect(id: GroupsNamespace.groupDescription + group.id, in: namespace)
            }
        }
    }
}
