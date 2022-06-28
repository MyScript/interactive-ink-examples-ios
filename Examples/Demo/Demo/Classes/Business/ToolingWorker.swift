// Copyright @ MyScript. All rights reserved.

import Foundation

/**
 * Protocol describing the ToolingWorker interface
 */

protocol ToolingWorkerLogic {
    func selectTool(tool: IINKPointerTool, activePenModeEnabled: Bool) throws
    func didChangeActivePenMode(activated: Bool) throws
    func didSelectStyle(style: ToolStyleModel) throws
    var editor: IINKEditor? { get set }
}

/**
 * This worker is in charge of all the logic around the IINK ToolController
 */

class ToolingWorker: ToolingWorkerLogic {

    enum ToolingError: Error {
        case lassoNotSupported
        case setToolFailed
        case setToolStyleFailed
        case noPartType
    }

    // the editor is not passed at init because it's not available at that moment
    weak var editor: IINKEditor?

    func selectTool(tool: IINKPointerTool, activePenModeEnabled: Bool) throws {
        guard let editor = self.editor,
              let partType = editor.part?.type else {
                  throw ToolingError.noPartType
              }
        if tool == .toolSelector && !self.isLassoAvailable(for: partType) {
            throw ToolingError.lassoNotSupported
        }
        do {
            try self.editor?.toolController.set(tool: tool, forType: .pen)
            // force hand tool for touch input type if activePen mode is enabled
            let toolForTouch: IINKPointerTool = activePenModeEnabled ? .hand : tool
            try self.editor?.toolController.set(tool: toolForTouch, forType: .touch)
        } catch {
            throw ToolingError.setToolFailed
        }
    }

    func didChangeActivePenMode(activated: Bool) throws {
        if activated == true {
            do {
                // Fall back to tool pen for penInput if it was set to tool hand
                if let tool = try? self.editor?.toolController.tool(forType: .pen),
                   tool.value == .hand {
                    try self.editor?.toolController.set(tool: .toolPen, forType: .pen)
                }
                // Fall back to tool hand for touchInput if activePenMode enabled
                try self.editor?.toolController.set(tool: .hand, forType: .touch)
            } catch {
                throw ToolingError.setToolFailed
            }
        } else {
            do {
                if let tool = try? self.editor?.toolController.tool(forType: .pen) {
                    try self.editor?.toolController.set(tool: tool.value, forType: .touch)
                }
            } catch {
                throw ToolingError.setToolFailed
            }
        }
    }

    func didSelectStyle(style: ToolStyleModel) throws {
        let colorHexa = style.currentColor.rawValue
        let width = style.currentWidth.rawValue
        let styleString = String(format: "color:%@;-myscript-pen-width:%.3f", colorHexa, width)
        do {
            try self.editor?.toolController.set(style: styleString, forTool: style.tool)
        } catch {
            throw ToolingError.setToolStyleFailed
        }
    }

    private func isLassoAvailable(for partType: String) -> Bool {
        return partType == "Raw Content" || partType == "Diagram" || partType == "Text Document"
    }
}
