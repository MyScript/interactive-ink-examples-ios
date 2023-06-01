// Copyright @ MyScript. All rights reserved.

import Foundation

struct ContextualActionsHelper {

    /**
     * Describes the actions available for a given selection or block.
     */
    struct ContextualAction: OptionSet {
        let rawValue: Int
        static let addBlock = ContextualAction(rawValue: 1 << 0)
        static let remove = ContextualAction(rawValue: 1 << 1)
        static let copy = ContextualAction(rawValue: 1 << 2)
        static let paste = ContextualAction(rawValue: 1 << 3)
        static let exportData = ContextualAction(rawValue: 1 << 4)
        static let convert = ContextualAction(rawValue: 1 << 5)
        static let formatText = ContextualAction(rawValue: 1 << 6)
    }

    /**
     * Returns the available actions for a block or for a selection
     */
    static func availableActions(forContent content: NSObjectProtocol & IINKIContentSelection, editor: IINKEditor) -> [ContextualAction] {
        var actions = [ContextualAction]()
        if let block = content as? IINKContentBlock {
            actions = self.availableActions(forBlock: block, editor: editor)
        } else if let selection = content as? IINKContentSelection {
            actions = self.availableActions(forSelection: selection, editor: editor)
        }
        return actions
    }

    /**
     * Returns the available actions for a block.
     */
    static func availableActions(forBlock block: IINKContentBlock, editor: IINKEditor) -> [ContextualAction] {

        let isRootBlock: Bool = block.identifier == editor.rootBlock?.identifier
        let onTextDocument: Bool = editor.part?.type == "Text Document"
        let blockIsEmpty: Bool = editor.isEmpty(block)

        let displayAddBlock: Bool = editor.supportedAddBlockTypes.count > 0 && (!onTextDocument || isRootBlock)
        let displayRemove: Bool = !isRootBlock
        let displayCopy: Bool = !isRootBlock || !onTextDocument
        let displayPaste: Bool = isRootBlock
        let displayConvert: Bool = !blockIsEmpty && editor.supportedTargetConversionState(forSelection: block).count > 0
        let displayExport: Bool = editor.supportedExportMimeTypes(forSelection: block).count > 0
        let displayFormatText: Bool = editor.supportedTextFormats(forSelection: block).count > 0

        var actions = [ContextualAction]()
        if displayAddBlock {
            actions.append(.addBlock)
        }
        if displayRemove {
            actions.append(.remove)
        }
        if displayCopy {
            actions.append(.copy)
        }
        if displayPaste {
            actions.append(.paste)
        }
        if displayConvert {
            actions.append(.convert)
        }
        if displayExport {
            actions.append(.exportData)
        }
        if displayFormatText {
            actions.append(.formatText)
        }

        return actions
    }

    /**
     * Returns the available actions for a selection.
     */
    static func availableActions(forSelection selection: IINKContentSelection, editor: IINKEditor) -> [ContextualAction] {

        let displayConvert: Bool = editor.supportedTargetConversionState(forSelection: selection).count > 0
        let displayFormatText: Bool = editor.supportedTextFormats(forSelection: selection).count > 0

        var actions = [ContextualAction]()
        actions.append(.copy)
        actions.append(.remove)
        if displayConvert {
            actions.append(.convert)
        }
        if displayFormatText {
            actions.append(.formatText)
        }

        return actions
    }
}
