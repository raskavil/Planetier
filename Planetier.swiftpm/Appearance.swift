import SwiftUI

/// Images by Freepik
enum Appearance: String, CaseIterable {
    
    case mars, mercury, neptune, emerald, titan, luna
    
    var image: Image {
        switch self {
            case .emerald:  return .init(.emeraldBackground)
            case .mars:     return .init(.marsBackground)
            case .luna:     return .init(.lunaBackground)
            case .neptune:  return .init(.neptuneBackground)
            case .titan:    return .init(.titanBackground)
            case .mercury:  return .init(.mercuryBackground)
        }
    }
    
    var color: Color {
        switch self {
            case .emerald:  return .init(.emerald)
            case .mars:     return .init(.mars)
            case .luna:     return .init(.luna)
            case .neptune:  return .init(.neptune)
            case .titan:    return .init(.titan)
            case .mercury:  return .init(.mercury)
        }
    }
    
    var name: String {
        rawValue.capitalized
    }
}
