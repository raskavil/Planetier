import SwiftData
import Foundation

@Model
class Group {

    @Attribute(.unique) let id: String
    let creationDate: Date
    var name: String
    var planetName: String
    
    init(
        id: String,
        creationDate: Date,
        name: String,
        planetName: String
    ) {
        self.id = id
        self.creationDate = creationDate
        self.name = name
        self.planetName = planetName
    }
}
