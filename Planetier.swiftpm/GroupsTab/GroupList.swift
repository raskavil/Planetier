import SwiftUI
import SwiftData

struct GroupList: View {
    
    @Namespace var namespace
    @Environment(\.modelContext) var modelContext
    @Query var groups: [Group]
    @State var editInput: GroupEditViewInput?
    @State var expandedGroup: Group?
    @State var presentedGroupToDelete: Group?
    
    var body: some View {
        ScrollView {
            VStack(spacing: .medium) {
                ForEach(groups) { (group: Group) in
                    GroupCell(
                        group: group,
                        expand: { group in
                            withAnimation {
                                expandedGroup = group
                            }
                        },
                        delete: { presentedGroupToDelete = $0 },
                        edit: { editInput = .edit($0) },
                        namespace: namespace
                    )
                    .clipShape(RoundedRectangle(cornerRadius: .defaultRadius))
                    .clipped()
                }
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(height: .default)
            }
            .padding(.horizontal, .default)
        }
        .navigationTitle(String(localized: "tab.groups"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "plus") {
                    editInput = .new
                }
            }
        }
        .groupView(
            $expandedGroup,
            delete: { group in withAnimation { presentedGroupToDelete = group } },
            edit: { group in withAnimation { editInput = .edit(group) } },
            namespace: namespace
        )
        .groupEditView(input: $editInput)
        .dialog(
            isPresented: .init(
                get: { presentedGroupToDelete != nil },
                set: { presentedGroupToDelete = $0 ? presentedGroupToDelete : nil }
            ),
            accessoryView: Image("delete", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150),
            title: .init(localized: "task.delete"),
            text: .init(localized: "group.delete.confirmation"),
            buttonTitle: .init(localized: "task.delete"),
            buttonStyle: .init(backgroundColor: .red),
            confirmation: {
                if let presentedGroupToDelete {
                    self.presentedGroupToDelete = nil
                    if expandedGroup == presentedGroupToDelete {
                        expandedGroup = nil
                    }
                    modelContext.delete(presentedGroupToDelete)
                }
            }
        )
    }
}

#Preview {
    GroupList()
}
