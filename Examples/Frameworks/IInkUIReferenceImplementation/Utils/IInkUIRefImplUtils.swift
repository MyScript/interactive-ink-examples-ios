// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// Color Utils

class IInkUIRefImplUtils:NSObject {

    @objc static func redComponentFromColor(colorInt32:UInt32) -> Float {
        return Float(colorInt32 >> 24 & 0xff) / Float(255)
    }

    @objc static func greenComponentFromColor(colorInt32:UInt32) -> Float {
        return Float(colorInt32 >> 16 & 0xff) / Float(255)
    }

    @objc static func blueComponentFromColor(colorInt32:UInt32) -> Float {
        return Float(colorInt32 >> 8 & 0xff) / Float(255)
    }

    @objc static func alphaComponentFromColor(colorInt32:UInt32) -> Float {
        return Float(colorInt32 & 0xff) / Float(255)
    }

    @objc static func uiColor(rgba:UInt32) -> UIColor {
        return UIColor(red: CGFloat((rgba >> 24) & 0xff) / 255,
                            green: CGFloat((rgba >> 16) & 0xff) / 255,
                            blue: CGFloat((rgba >> 8) & 0xff) / 255,
                            alpha: CGFloat((rgba & 0xff)) / 255)
    }
}
