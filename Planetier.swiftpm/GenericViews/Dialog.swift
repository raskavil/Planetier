import SwiftUI

struct DialogModifier: ViewModifier {
    
    let isPresented: Binding<Bool>
    let confirmation: () -> Void
    
    func body(content: Content) -> some View {
        Dialog(isPresented: isPresented, confirmation: confirmation, content: { content })
    }
}

extension View {
    
    func dialog(isPresented: Binding<Bool>, confirmation: @escaping () -> Void) -> some View {
        modifier(DialogModifier(isPresented: isPresented, confirmation: confirmation))
    }
}

struct Dialog<Content: View>: View {
    
    @Binding var isPresented: Bool
    let content: Content
    let confirmation: () -> Void
    
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
                    Text("Delete?")
                        .bold()
                        .font(.title)
                    Text("Do you really want to delete this task?")
                    LargeButton(title: "Delete", action: confirmation)
                        .padding(.top, .medium)
                }
                .padding(.default)
                .background {
                    RoundedRectangle(cornerRadius: .defaultRadius)
                        .foregroundStyle(.white)
                }
                .frame(width: 300)
                .presentationBackground {
                    Color.black.opacity(0.3)
                        .onTapGesture {
                            isPresented = false
                        }
                }
                .presentationBackgroundInteraction(.enabled)
            }
    }
    
    init(isPresented: Binding<Bool>, confirmation: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        _isPresented = isPresented
        self.confirmation = confirmation
        self.content = content()
    }
}
