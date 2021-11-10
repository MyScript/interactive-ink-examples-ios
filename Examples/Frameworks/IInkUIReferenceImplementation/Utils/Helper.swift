// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

enum ModelName {
    case iPadMini
    case iPadMiniRetina
    case iPhoneX
    case unknown
}

/// Device Utils

class Helper {

    static let kDpiPhone:Float = 326
    static let kDpiPhonePlus:Float = 401
    static let kDpiPhoneX:Float = 463
    static let kDpiPad:Float = 132
    static let kDpiPadMini:Float = 163
    static let kDpiPadMiniRetina:Float = 324
    static let kDpiPadRetina:Float = 264

    static func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    static func isPadMini() -> Bool {
        return UIDevice.current.modelName == .iPadMini
    }

    static func isPadMiniRetina() -> Bool {
        return UIDevice.current.modelName == .iPadMiniRetina
    }

    static func isPadRetina() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad && UIScreen.main.scale > 1
    }

    static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    static func isPhoneX() -> Bool {
        return UIDevice.current.modelName == .iPhoneX
    }

    static func isPhonePlus() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.scale > 2
    }

    static func dpi() -> Float {
        if isPhone() {
            if isPhoneX() {
                return Helper.kDpiPhoneX
            } else if isPhonePlus() {
                return Helper.kDpiPhonePlus
            }
            return Helper.kDpiPhone
        }
        if isPad() {
            if isPadMini() {
                return Helper.kDpiPadMini
            } else if isPadMiniRetina() {
                return Helper.kDpiPadMiniRetina
            } else if isPadRetina() {
                return Helper.kDpiPadRetina
            }
            return Helper.kDpiPad
        }
        return 0
    }

    static func scaledDpi() -> Float {
        return Helper.dpi()/Float(UIScreen.main.scale)
    }
}

extension UIDevice {
    // All cases of model names are not covered for purpose, we just cover the needs of the Helper. Feel free to add more model names if needed.
    var modelName: ModelName {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
            case "iPhone10,3", "iPhone10,6":                return .iPhoneX
            case "iPad2,5", "iPad2,6", "iPad2,7":           return .iPadMini
            case "iPad4,4", "iPad4,5", "iPad4,6",
                 "iPad4,7", "iPad4,8", "iPad4,9",
                 "iPad5,1", "iPad5,2":                      return .iPadMiniRetina
            default:                                        return .unknown
        }
    }
}
