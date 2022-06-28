// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

// MARK: ToolBar

struct ToolbarButtonModel: Equatable {
    var tintColor: UIColor = .black
    var title: String? = nil
    var enabled: Bool = false
    var width: CGFloat = 60
    var selected: Bool = false

    mutating func selectTool(select:Bool) {
        self.selected = select
        self.tintColor = select ? .systemBlue : .black
    }
}

struct ActivePenModel: Equatable {
    var labelColor: UIColor = .black
    var labelText: String = ""
    var switchColor: UIColor = .systemBlue
    var enabled: Bool = false
}

// MARK: ToolStyle

enum ToolWidth: Float {
    case penThin = 0.208 // 0.625 / 3
    case penMedium = 0.625
    case penLarge = 1.875 // 0.625 * 3
    case hightlighterThin = 1.666  // 5 / 3
    case hightlighterMedium = 5
    case hightlighterLarge = 15 // 5 * 3
}

enum ToolColor: String {
    case penBlack = "#000000"
    case penRed = "#EA4335FF"
    case penGreen = "#34A853"
    case penBlue = "#4285F4"
    case highlighterYellow = "#FBBC0566"
    case highlighterRed = "#EA433566"
    case highlighterGreen = "#34A85366"
    case highlighterBlue = "#4285F466"
}

struct ColorButtonModel: Equatable {
    var color: UIColor
    var radius: CGFloat = 20 // Default value for Toolbar Storyboard
    var isSelected:Bool = false
    var borderColor: CGColor? = UIColor.clear.cgColor
    var borderWidth: CGFloat = 4
}

struct ToolStyleModel: Equatable {
    var tool: IINKPointerTool
    var currentColor:ToolColor
    var currentWidth:ToolWidth
}

struct WidthSegmentedControlModel: Equatable {
    var selectedSegment:Int
}
