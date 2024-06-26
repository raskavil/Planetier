import SwiftUI

struct Checkbox<Content: View>: View {
    
    @Binding var isSelected: Bool
    let label: Content
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            HStack(spacing: .medium) {
                label
                RoundedRectangle(cornerRadius: .small)
                    .stroke(.black, lineWidth: 2)
                    .foregroundStyle(.clear)
                    .frame(width: .large, height: .large)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: .small)
                                .foregroundStyle(.blue)
                                .transition(.opacity)
                                .overlay {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .bold()
                                        .padding(.small)
                                }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.1)) {
                            isSelected.toggle()
                        }
                    }
                    .padding(1)
            }
        }
    }
    
    init(isSelected: Binding<Bool>, label: Content = EmptyView()) {
        self._isSelected = isSelected
        self.label = label
    }
    
    init(isSelected: Binding<Bool>, @ViewBuilder label: () -> Content) {
        self.init(isSelected: isSelected, label: label())
    }
}
