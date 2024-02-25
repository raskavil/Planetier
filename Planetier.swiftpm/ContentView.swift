import SwiftUI

struct ContentView: View {
    
    enum Tab: Hashable {
        case tasks, groups, planning, preferences
    }
    
    @Environment(\.navigation) var navigation
    @State var selectedTab: Tab = .tasks
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TasksTab()
                .tabItem {
                    Label("tab.tasks", systemImage: "list.bullet.clipboard")
                }
                .tag(Tab.tasks)
            GroupsTab()
                .tabItem {
                    Label("tab.groups", systemImage: "rectangle.3.group.fill")
                }
                .tag(Tab.groups)
            Text("Planning")
                .tabItem {
                    Label("Planning", systemImage: "calendar")
                }
                .tag(Tab.planning)
            Text("Preferences")
                .tabItem {
                    Label("Preferences", systemImage: "gear")
                }
                .tag(Tab.preferences)
        }
        .onAppear {
            navigation.add(action: { destination in
                switch destination {
                    case .createNewGroup:   self.selectedTab = .groups
                }
            }, withId: String(describing: Self.self))
        }
    }
}
