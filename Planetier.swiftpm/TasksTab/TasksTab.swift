import SwiftUI

struct TasksTab: View {
    
    @State var representedTask: ToDoTaskRepresentation?
    
    var body: some View {
        NavigationStack {
            TaskList()
        }
    }
}
