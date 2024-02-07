import SwiftUI

/// ScrollView with LinearGradient added over the contentInsets.
/// Use in order to improve the feeling of content continuity.
struct GradientScrollView<Content: View>: View {
    
    let axes: Axis.Set
    let content: Content
    let contentInsets: EdgeInsets
    let gradientColors: [Color]
    
    var body: some View {
        ScrollView(axes) {
            content
                .padding(contentInsets)
        }
        .overlay(alignment: .center) {
            if contentInsets.leading != 0 || contentInsets.trailing != 0 {
                HStack {
                    LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                        .frame(width: contentInsets.leading)
                    Spacer()
                    LinearGradient(colors: gradientColors, startPoint: .trailing, endPoint: .leading)
                        .frame(width: contentInsets.trailing)
                }
            }
            if contentInsets.top != 0 || contentInsets.bottom != 0 {
                VStack {
                    LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
                        .frame(height: contentInsets.top)
                    Spacer()
                    LinearGradient(colors: gradientColors, startPoint: .bottom, endPoint: .top)
                        .frame(height: contentInsets.bottom)
                }
            }
        }
    }
    
    
    init(
        axes: Axis.Set = .vertical,
        contentInsets: EdgeInsets,
        gradientColors: [Color] = [.white, .clear],
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.contentInsets = contentInsets
        self.gradientColors = gradientColors
        self.content = content()
    }
}

extension EdgeInsets {
    
    init(vertical: CGFloat = 0, horizontal: CGFloat = 0) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
