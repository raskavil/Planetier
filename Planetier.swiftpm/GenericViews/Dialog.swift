import SwiftUI

struct DialogModifier<Accessory: View>: ViewModifier {
    
    let isPresented: Binding<Bool>
    let accessoryView: Accessory?
    let title: String
    let text: String
    let buttonTitle: String
    let buttonStyle: LargeButton.Style
    let confirmation: () -> Void
    
    func body(content: Content) -> some View {
        Dialog(
            isPresented: isPresented,
            accessoryView: accessoryView,
            title: title,
            text: text,
            buttonTitle: buttonTitle,
            buttonStyle: buttonStyle,
            confirmation: confirmation,
            content: { content }
        )
    }
}

extension View {
    
    func dialog<Accessory: View>(
        isPresented: Binding<Bool>,
        accessoryView: Accessory? = nil,
        title: String,
        text: String = "",
        buttonTitle: String = "",
        buttonStyle: LargeButton.Style = .init(),
        confirmation: @escaping () -> Void = {}
    ) -> some View {
        modifier(DialogModifier(
            isPresented: isPresented,
            accessoryView: accessoryView,
            title: title,
            text: text,
            buttonTitle: buttonTitle,
            buttonStyle: buttonStyle,
            confirmation: confirmation
        ))
    }
}
struct Dialog<Content: View, Accessory: View>: View {
    
    @Binding var isPresented: Bool
    let accessoryView: Accessory?
    let title: String
    let text: String
    let buttonTitle: String
    let buttonStyle: LargeButton.Style
    let confirmation: () -> Void
    let content: Content
    
    var body: some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                VStack(alignment: .leading, spacing: .medium) {
                    HStack {
                        Button { isPresented = false } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                                .bold()
                        }
                        Spacer()
                    }
                    if let accessoryView {
                        HStack {
                            Spacer()
                            accessoryView
                                .frame(maxWidth: 250)
                            Spacer()
                        }
                    }
                    Text(title)
                        .bold()
                        .font(.title3)
                    if text.isEmpty == false {
                        Text(text)
                    }
                    if buttonTitle.isEmpty == false {
                        LargeButton(title: buttonTitle, action: confirmation, style: buttonStyle)
                            .padding(.top, .medium)
                    }
                }
                .frame(width: 250)
                .padding(.default)
                .background {
                    RoundedRectangle(cornerRadius: .defaultRadius)
                        .foregroundStyle(.white)
                }
                .presentationBackground {
                    Color.black.opacity(0.3)
                        .onTapGesture {
                            isPresented = false
                        }
                }
                .presentationBackgroundInteraction(.enabled)
            }
    }
    
    init(
        isPresented: Binding<Bool>,
        accessoryView: Accessory?,
        title: String,
        text: String,
        buttonTitle: String,
        buttonStyle: LargeButton.Style,
        confirmation: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        _isPresented = isPresented
        self.accessoryView = accessoryView
        self.title = title
        self.text = text
        self.buttonTitle = buttonTitle
        self.buttonStyle = buttonStyle
        self.confirmation = confirmation
        self.content = content()
    }
}
