import SwiftUI

struct Collection: Layout {
    
    var horizontalSpacing: CGFloat = .small
    var verticalSpacing: CGFloat = .small
    var alignment: VerticalAlignment = .top
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let subviewFrames = layoutViewsWith(subviews.map { $0.dimensions(in: proposal) }, for: proposal.width)
        return .init(
            width: proposal.width ?? subviewFrames.map(\.maxX).max() ?? 0,
            height: subviewFrames.map(\.maxY).max() ?? 0
        )
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        zip(subviews, layoutViewsWith(subviews.map { $0.dimensions(in: .unspecified) }, for: bounds.width))
            .forEach { subview, frame in
                subview.place(
                    at: .init(x: frame.origin.x + bounds.origin.x, y: frame.origin.y + bounds.origin.y),
                    proposal: .unspecified
                )
            }
    }
    
    private func layoutViewsWith(_ dimensions: [ViewDimensions], for width: CGFloat?) -> [CGRect] {
        guard let width, width >= dimensions.map(\.width).max() ?? 0 else {
            return dimensions.reduce(into: (currentY: 0.0, frames: [CGRect]())) { partialResult, dimensions in
                partialResult.frames.append(
                    .init(
                        x: 0,
                        y: partialResult.currentY,
                        width: dimensions.width,
                        height: dimensions.height
                    )
                )
                partialResult.currentY += dimensions.height + verticalSpacing
            }.frames
        }
        
        guard width != .infinity else {
            return dimensions.reduce(into: (currentX: 0.0, frames: [CGRect]())) { partialResult, dimensions in
                partialResult.frames.append(
                    .init(
                        x: partialResult.currentX,
                        y: 0,
                        width: dimensions.width,
                        height: dimensions.height
                    )
                )
                partialResult.currentX += dimensions.width + horizontalSpacing
            }.frames
        }
        
        return dimensions.reduce(into: (x: 0.0, y: 0.0, rowHeight: 0.0, frames: [CGRect]())) { partialResult, dimensions in
            if partialResult.x != 0 {
                partialResult.x += horizontalSpacing
            }
            
            if (partialResult.x + dimensions.width) > width {
                partialResult.y += partialResult.rowHeight + verticalSpacing
                partialResult.x = 0
                partialResult.rowHeight = 0
            }
            
            partialResult.frames.append(
                .init(
                    x: partialResult.x,
                    y: partialResult.y,
                    width: dimensions.width,
                    height: dimensions.height
                )
            )
            
            partialResult.x += dimensions.width
            partialResult.rowHeight = max(dimensions.height, partialResult.rowHeight)
        }.frames
    }
}

extension Swift.Collection where Element: AdditiveArithmetic {
    
    var sum: Element {
        guard var returnValue = first else { return .zero }
        dropFirst().forEach { returnValue += $0 }
        return returnValue
    }
}

#Preview {
    Collection {
        ForEach(0...15, id: \.self) { _ in
            Rectangle()
                .frame(width: 50, height: 50)
        }
    }
    .background(.red)
}
