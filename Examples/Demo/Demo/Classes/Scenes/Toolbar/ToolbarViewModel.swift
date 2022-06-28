// Copyright @ MyScript. All rights reserved.

import Combine
import Foundation

class ToolbarViewModel {

    // MARK: Published Properties

    @Published var selectedTool: IINKPointerTool?
    // UI Models
    @Published var penToolModel: ToolbarButtonModel?
    @Published var handToolModel: ToolbarButtonModel?
    @Published var eraserToolModel: ToolbarButtonModel?
    @Published var lassoToolModel: ToolbarButtonModel?
    @Published var highlighterToolModel: ToolbarButtonModel?
    @Published var undoButtonModel: ToolbarButtonModel?
    @Published var redoButtonModel: ToolbarButtonModel?
    @Published var clearButtonModel: ToolbarButtonModel?
    @Published var activePenModel: ActivePenModel?
    @Published var styleButtonEnabled: Bool = true
    @Published var enablePanGesture: Bool = true
    // ToolStyle State Models
    @Published var penStyleModel: ToolStyleModel?
    @Published var highlighterStyleModel: ToolStyleModel?

    // MARK: Properties

    private var activePenModeEnabled: Bool = true

    // MARK: Business Logic

    func setup() {
        self.initModels()
        self.selectPenTool()
        self.didChangeActivePenMode(activated: true)
    }

    func getStyleForActiveTool() -> ToolStyleModel? {
        switch self.selectedTool {
        case .toolPen:
            return self.penStyleModel
        case .toolHighlighter:
            return self.highlighterStyleModel
        default:
            return nil
        }
    }

    func enableEditing(enable: Bool) {
        self.penToolModel?.enabled = enable
        self.handToolModel?.enabled = enable
        self.lassoToolModel?.enabled = enable
        self.highlighterToolModel?.enabled = enable
        self.eraserToolModel?.enabled = enable
        self.undoButtonModel?.enabled = enable
        self.redoButtonModel?.enabled = enable
        self.clearButtonModel?.enabled = enable
        self.activePenModel?.enabled = enable
    }

    func selectPenTool() {
        self.selectedTool = .toolPen
        self.resetToolSelection()
        self.penToolModel?.selectTool(select: true)
        self.styleButtonEnabled = true
        self.enablePanGesture = self.activePenModeEnabled
    }

    func selectHandTool() {
        self.selectedTool = .hand
        self.resetToolSelection()
        self.handToolModel?.selectTool(select: true)
        self.styleButtonEnabled = false
        self.enablePanGesture = true
    }

    func selectEraserTool() {
        self.selectedTool = .eraser
        self.resetToolSelection()
        self.eraserToolModel?.selectTool(select: true)
        self.styleButtonEnabled = false
        self.enablePanGesture = self.activePenModeEnabled
    }

    func selectLassoTool() {
        self.selectedTool = .toolSelector
        self.resetToolSelection()
        self.lassoToolModel?.selectTool(select: true)
        self.styleButtonEnabled = false
        self.enablePanGesture = self.activePenModeEnabled
    }

    func selectHighlighterTool() {
        self.selectedTool = .toolHighlighter
        self.resetToolSelection()
        self.highlighterToolModel?.selectTool(select: true)
        self.styleButtonEnabled = true
        self.enablePanGesture = self.activePenModeEnabled
    }

    func didChangeActivePenMode(activated: Bool) {
        // hide hand tool if activePen mode is enabled,
        self.handToolModel?.width = activated ? 0 : 60
        // and fall back to pen if hand was selected
        if handToolModel?.selected == true {
            self.selectPenTool()
        }
        // Disable editorVC panGesture if activePen mode disabled except for hand tool
        if activated {
            self.enablePanGesture = true
        } else {
            self.enablePanGesture = self.selectedTool == .hand
        }
        self.activePenModeEnabled = activated
    }

    private func initModels() {
        self.penToolModel = ToolbarButtonModel()
        self.handToolModel = ToolbarButtonModel()
        self.lassoToolModel = ToolbarButtonModel()
        self.highlighterToolModel = ToolbarButtonModel()
        self.eraserToolModel = ToolbarButtonModel()
        self.undoButtonModel = ToolbarButtonModel(tintColor: .systemBlue)
        self.redoButtonModel = ToolbarButtonModel(tintColor: .systemBlue)
        self.clearButtonModel = ToolbarButtonModel(tintColor: .systemBlue)
        self.activePenModel = ActivePenModel(labelText: "Active Pen")
        // default style states for pen and highlighter
        self.penStyleModel = ToolStyleModel(tool:.toolPen,
                                            currentColor: .penBlack,
                                            currentWidth: .penMedium)
        self.highlighterStyleModel = ToolStyleModel(tool:.toolHighlighter,
                                                    currentColor: .highlighterYellow,
                                                    currentWidth: .hightlighterMedium)
    }

    private func resetToolSelection() {
        self.penToolModel?.selectTool(select:false)
        self.penToolModel?.selectTool(select:false)
        self.handToolModel?.selectTool(select:false)
        self.eraserToolModel?.selectTool(select:false)
        self.lassoToolModel?.selectTool(select:false)
        self.highlighterToolModel?.selectTool(select:false)
    }
}

extension ToolbarViewModel: ToolStyleProtocol {

    func didSelectStyle(style: ToolStyleModel) {
        switch style.tool {
        case .toolPen:
            self.penStyleModel = style
        case .toolHighlighter:
            self.highlighterStyleModel = style
        default:
            return
        }
    }
}
