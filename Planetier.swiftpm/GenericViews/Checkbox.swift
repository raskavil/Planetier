import SwiftUI

struct Checkbox: View {
    
    @Binding var isSelected: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: .small)
            .stroke(.black, lineWidth: 2)
            .frame(width: 20, height: 20)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: .small)
                        .foregroundStyle(.blue)
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
