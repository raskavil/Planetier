import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView() {
            TasksTab()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet.clipboard")
                }
            GroupsTab()
                .tabItem {
                    Label("Groups", systemImage: "rectangle.3.group.fill")
                }
            Text("Planning")
                .tabItem {
                    Label("Planning", systemImage: "calendar")
                }
            Text("Preferences")
                .tabItem {
                    Label("Preferences", systemImage: "gear")
                }
        }
    }
}
