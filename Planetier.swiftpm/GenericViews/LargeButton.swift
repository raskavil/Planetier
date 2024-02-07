import SwiftUI

struct LargeButton: View {
    
    struct Style {
        var foregroundColor = Color.white
        var backgroundColor = Color.blue
    }
    
    let title: String
    let action: () -> Void
    let style: Style
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .bold()
                .foregroundStyle(style.foregroundColor)
                .padding(.default)
                .frame(maxWidth: .infinity)
                .background {
                    background
                }
        }
    }
    
    @ViewBuilder private var background: some View {
        RoundedRectangle(cornerRadius: .defaultRadius)
            .foregroundStyle(style.backgroundColor)
    }
    
    init(title: String, action: @escaping () -> Void, style: Style = .init()) {
        self.title = title
        self.action = action
        self.style = style
    }
}
