import SwiftUI

struct GroupList: View {
    
    @Environment(\.modelContext) var modelContext
    @State var editInput: GroupEditViewInput?
    
    var body: some View {
        ScrollView {
            VStack(spacing: .medium) {
                SortedQueryForEach(sort: []) { group in
                    GroupCell(
                        group: group,
                        delete: { modelContext.delete($0) },
                        edit: { editInput = .edit($0) }
                    )
                        .clipShape(RoundedRectangle(cornerRadius: .defaultRadius))
                        .clipped()
                }
            }
            .padding(.horizontal, .default)
        }
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "plus") {
                    editInput = .new
                }
            }
        }
        .groupEditView(input: $editInput)
    }
}

#Preview {
    GroupList()
}
