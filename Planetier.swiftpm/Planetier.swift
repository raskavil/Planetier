import SwiftUI
import SwiftData

@main
struct Planetier: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ToDoTask.self, inMemory: true)
    }
}
