// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// Font Helper to load Custom Fonts and Init Fonts from IINKStyle

extension UIFont {

    // MARK: - Custom Fonts

    static func fontFromStyle(style: IINKStyle, string:String) -> UIFont? {
        guard let fontFamily = style.fontFamily else {
            return nil
        }
        var font:UIFont?
        let isBold = style.fontWeight >= 700
        let isItalic = style.fontStyle.lowercased() == "italic"
        if fontFamily != "sans-serif" {
            font = UIFont(name: fontFamily, size: CGFloat(style.fontSize))
            // fallback on STIX One font when STIX Two is not available
            if (font == nil && fontFamily == "STIX Two Math") {
                font = UIFont(name: "STIXGeneral", size: CGFloat(style.fontSize))
            }
            else if (font == nil && fontFamily == "STIX Two Text") {
                font = UIFont(name: "STIXGeneral-Italic", size: CGFloat(style.fontSize))
            }
        } else {
            font = UIFont.systemFont(ofSize: CGFloat(style.fontSize), weight: .regular)
        }
        if isItalic {
            font = font?.italicFont()
        } else if isBold {
            font = font?.boldFont()
        }
        return font
    }

    static func fontFromStyle(style:IINKStyle) -> UIFont? {
        return UIFont.fontFromStyle(style: style, string: "a")
    }

    // MARK: - Traits

    func italicFont() -> UIFont {
        if let font = withTraits(traits: .traitItalic) {
            return font
        }
        return self
    }

    func boldFont() -> UIFont {
        if let font = withTraits(traits: .traitBold) {
            return font
        }
        return self
    }

    private func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont? {
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: self.pointSize)
        }
        return nil
    }
}
