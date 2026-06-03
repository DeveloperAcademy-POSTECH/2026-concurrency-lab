import SwiftUI
import UIKit

/// Family name registered by the Pretendard variable font.
private let pretendardFamily = "Pretendard Variable"
/// PostScript name of the font's default instance.
private let pretendardPostScript = "PretendardVariable-Regular"

extension Font {
    /// Pretendard font that scales with Dynamic Type.
    /// - Parameters:
    ///   - size: point size at the default content size.
    ///   - weight: weight along the variable font's wght axis.
    ///   - textStyle: the text style to scale relative to.
    static func pretendard(
        _ size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        .custom(pretendardFamily, size: size, relativeTo: textStyle).weight(weight)
    }
}

extension UIFont {
    /// Pretendard `UIFont` (for UIKit-backed surfaces like the navigation bar).
    static func pretendard(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont(name: pretendardPostScript, size: size)
            ?? .systemFont(ofSize: size, weight: weight)
        // Drive the variable font's weight axis via the weight trait.
        let descriptor = base.fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: size)
    }
}
