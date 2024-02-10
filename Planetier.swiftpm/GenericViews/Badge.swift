import SwiftUI

struct Badge: View {
    
    struct Style {
        let contentColor: Color
        let backgroundColor: Color
        let borderColor: Color
        
        public init(contentColor: Color = .black, backgroundColor: Color = .white, borderColor: Color = .black) {
            self.contentColor = contentColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
        }
    }
    
    let image: Image?
    let text: String
    let style: Style
    
    var body: some View {
        HStack(spacing: .medium) {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .bold()
                    .frame(width: .large, height: .large)
                    .foregroundStyle(style.contentColor)
            }
            Text(text)
                .foregroundStyle(style.contentColor)
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .small)
        .background {
            RoundedRectangle(cornerRadius: .defaultRadius)
                .foregroundStyle(style.backgroundColor)
        }
        .background {
            RoundedRectangle(cornerRadius: .defaultRadius)
                .stroke(style.borderColor, lineWidth: 2)
        }
        .padding(1)
        .fixedSize()
    }
    
    init(text: String = "", image: Image? = nil, style: Style = .init()) {
        self.text = text
        self.image = image
        self.style = style
    }
}

#Preview {
    Badge(
        text: "High",
        image: Image(systemName: "chevron.up.square"),
        style: .init(contentColor: .white, backgroundColor: .red, borderColor: .clear)
    )
}
