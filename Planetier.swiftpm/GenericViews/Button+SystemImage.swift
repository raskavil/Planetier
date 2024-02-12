import SwiftUI

extension Button where Label == Image {
    
    init(systemImage: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Image(systemName: systemImage)
        }
    }
}

struct SystemImageButtonPreviews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            Button(systemImage: "plus", action: {})
            Button(systemImage: "bus", action: {})
        }
    }
}
