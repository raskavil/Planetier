import SwiftUI

struct GroupList: View {
    var body: some View {
        ScrollView {
            SortedQueryForEach(sort: []) { (group: Group) in
                Text(group.name)
            }
        }
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "plus") {
                    
                }
            }
        }
    }
}

#Preview {
    GroupList()
}
