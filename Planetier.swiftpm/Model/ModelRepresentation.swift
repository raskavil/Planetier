import SwiftData

protocol ModelRepresentation {
    associatedtype RepresentedType: PersistentModel
    
    var representedType: RepresentedType { get }
    init(representedType: RepresentedType)
    
    func setValues(on representedType: RepresentedType)
}
