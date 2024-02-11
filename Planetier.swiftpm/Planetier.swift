import SwiftUI
import SwiftData
import UIKit
import CoreData

@main
struct Planetier: App {
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: ToDoTask.self)
        } catch {
            fatalError()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
