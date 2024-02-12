import SwiftUI
import SwiftData

/// View used to query for SwiftData items and include them in a ForEach and simultaneously allow for a dynamic sort.
struct SortedQueryForEach<Item: PersistentModel, Content: View>: View {
    
    @Query var items: [Item]
    let content: (Item) -> Content
    
    @ViewBuilder var body: some View {
        ForEach(items, content: content)
    }
    
    init(sort: [SortDescriptor<Item>], @ViewBuilder content: @escaping (Item) -> Content) {
        self._items = .init(sort: sort)
        self.content = content
    }
}
