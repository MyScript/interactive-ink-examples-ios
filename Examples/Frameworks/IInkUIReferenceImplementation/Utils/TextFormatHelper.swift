// Copyright @ MyScript. All rights reserved.

import Foundation

struct TextFormatHelper {

    static func name(for format: IINKTextFormat) -> String {
        switch format {
        case .H1:
            return "H1"
        case .H2:
            return "H2"
        case .paragraph:
            return "Paragraph"
        @unknown default:
            return "Unknown Format"
        }
    }
}
