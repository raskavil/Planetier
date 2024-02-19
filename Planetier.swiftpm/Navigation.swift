import SwiftUI

struct NavigationKey: EnvironmentKey {
    
    static let defaultValue: NavigationObject = .init()
}

extension EnvironmentValues {
    
    var navigation: NavigationObject {
        get {
            self[NavigationKey.self]
        }
        set {
            self[NavigationKey.self] = newValue
        }
    }
}

class NavigationObject: ObservableObject {
    
    enum Destination: String {
        case createNewGroup
    }
    
    private var actions: [String: (Destination) -> Void] = [:]
    
    func add(action: ((Destination) -> Void)?, withId id: String) {
        actions[id] = action
    }
    
    func performNavigation(to destination: Destination) {
        actions.forEach({ $1(destination) })
    }
}
