import SwiftUI

struct TasksTab: View {
    
    @State var representedTask: ToDoTaskRepresentation?
    
    var body: some View {
        Button("Present edit task") {
            representedTask = .init()
        }
        .taskEditView(item: $representedTask) {
            print(representedTask!)
        }
    }
}
