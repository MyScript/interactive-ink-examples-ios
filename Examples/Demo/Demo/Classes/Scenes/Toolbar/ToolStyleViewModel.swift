// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

class ToolStyleViewModel {

    // MARK: Published Properties

    @Published var color1ButtonModel: ColorButtonModel?
    @Published var color2ButtonModel: ColorButtonModel?
    @Published var color3ButtonModel: ColorButtonModel?
    @Published var color4ButtonModel: ColorButtonModel?
    @Published var widthSegmentedControlModel: WidthSegmentedControlModel?
    @Published var futureStyleModel: ToolStyleModel?

    // MARK: Properties

    private var tool: IINKPointerTool
    private var currentStyleModel: ToolStyleModel

    // MARK: Business Logic

    init(tool:IINKPointerTool, toolStyle: ToolStyleModel) {
        self.tool = tool
        self.currentStyleModel = toolStyle
    }

    func setup() {
        self.initModels()
        self.applyCurrentState()
    }

    func selectColor1() {
        switch self.tool {
        case .toolPen:
            selectColor(newColor: .penBlack)
        case .toolHighlighter:
            selectColor(newColor: .highlighterYellow)
        default :
            return
        }
        self.deselectAllColors()
        self.color1ButtonModel?.borderColor = UIColor.lightGray.cgColor
    }

    func selectColor2() {
        switch self.tool {
        case .toolPen:
            selectColor(newColor: .penRed)
        case .toolHighlighter:
            selectColor(newColor: .highlighterRed)
        default :
            return
        }
        self.deselectAllColors()
        self.color2ButtonModel?.borderColor = UIColor.lightGray.cgColor
    }

    func selectColor3() {
        switch self.tool {
        case .toolPen:
            selectColor(newColor: .penGreen)
        case .toolHighlighter:
            selectColor(newColor: .highlighterGreen)
        default :
            return
        }
        self.deselectAllColors()
        self.color3ButtonModel?.borderColor = UIColor.lightGray.cgColor
    }

    func selectColor4() {
        switch self.tool {
        case .toolPen:
            selectColor(newColor: .penBlue)
        case .toolHighlighter:
            selectColor(newColor: .highlighterBlue)
        default :
            return
        }
        self.deselectAllColors()
        self.color4ButtonModel?.borderColor = UIColor.lightGray.cgColor
    }

    func widthSegmentedControlValueChanged(newIndex: Int) {
        var newWidth:ToolWidth = .penMedium
        let tuple = (self.tool, newIndex)
        switch tuple {
        case (.toolPen,0):
            newWidth = .penThin
        case (.toolPen,1):
            newWidth = .penMedium
        case (.toolPen,2):
            newWidth = .penLarge
        case (.toolHighlighter,0):
            newWidth = .hightlighterThin
        case (.toolHighlighter,1):
            newWidth = .hightlighterMedium
        case (.toolHighlighter,2):
            newWidth = .hightlighterLarge
        default:
            return
        }
        self.futureStyleModel = ToolStyleModel(tool: self.currentStyleModel.tool,
                                               currentColor: self.currentStyleModel.currentColor,
                                               currentWidth: newWidth)
        self.currentStyleModel.currentWidth = newWidth
    }

    private func selectColor(newColor: ToolColor) {
        self.futureStyleModel = ToolStyleModel(tool: self.currentStyleModel.tool,
                                               currentColor: newColor,
                                               currentWidth: self.currentStyleModel.currentWidth)
        self.currentStyleModel.currentColor = newColor
    }

    private func initModels() {
        var color1, color2, color3, color4: UIColor?
        switch self.tool {
        case .toolPen:
            color1 = UIColor.init(hexString: ToolColor.penBlack.rawValue)
            color2 = UIColor.init(hexString: ToolColor.penRed.rawValue)
            color3 = UIColor.init(hexString: ToolColor.penGreen.rawValue)
            color4 = UIColor.init(hexString: ToolColor.penBlue.rawValue)
        case .toolHighlighter:
            color1 = UIColor.init(hexString: ToolColor.highlighterYellow.rawValue)
            color2 = UIColor.init(hexString: ToolColor.highlighterRed.rawValue)
            color3 = UIColor.init(hexString: ToolColor.highlighterGreen.rawValue)
            color4 = UIColor.init(hexString: ToolColor.highlighterBlue.rawValue)
        default :
            break
        }
        self.color1ButtonModel = ColorButtonModel(color: color1 ?? .black)
        self.color2ButtonModel = ColorButtonModel(color: color2 ?? .black)
        self.color3ButtonModel = ColorButtonModel(color: color3 ?? .black)
        self.color4ButtonModel = ColorButtonModel(color: color4 ?? .black)
    }

    private func deselectAllColors() {
        self.color1ButtonModel?.borderColor = UIColor.clear.cgColor
        self.color2ButtonModel?.borderColor = UIColor.clear.cgColor
        self.color3ButtonModel?.borderColor = UIColor.clear.cgColor
        self.color4ButtonModel?.borderColor = UIColor.clear.cgColor
    }

    private func applyCurrentState() {
        switch self.currentStyleModel.currentColor {
        case .penBlack, .highlighterYellow:
            self.color1ButtonModel?.borderColor = UIColor.lightGray.cgColor
        case .penRed, .highlighterRed:
            self.color2ButtonModel?.borderColor = UIColor.lightGray.cgColor
        case .penGreen, .highlighterGreen:
            self.color3ButtonModel?.borderColor = UIColor.lightGray.cgColor
        case .penBlue, .highlighterBlue:
            self.color4ButtonModel?.borderColor = UIColor.lightGray.cgColor
        }
        switch self.currentStyleModel.currentWidth {
        case .penThin, .hightlighterThin:
            self.widthSegmentedControlModel = WidthSegmentedControlModel(selectedSegment: 0)
        case .penMedium, .hightlighterMedium:
            self.widthSegmentedControlModel = WidthSegmentedControlModel(selectedSegment: 1)
        case .penLarge, .hightlighterLarge:
            self.widthSegmentedControlModel = WidthSegmentedControlModel(selectedSegment: 2)
        }
    }

}
