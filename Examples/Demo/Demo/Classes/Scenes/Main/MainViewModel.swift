// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

protocol MainViewModelEditorLogic: AnyObject {
    func didCreatePackage(fileName: String)
    func didLoadPart(title: String, index: Int, partCount: Int)
    func didUnloadPart()
    func didOpenFile()
}

/// This class is the ViewModel of the MainViewController. It handles all its business logic.

class MainViewModel: NSObject {

    // MARK: - Published Properties

    @Published var title: String?
    // Alerts
    @Published var errorAlertModel: AlertModel?
    @Published var menuAlertModel: AlertModel?
    @Published var moreActionsAlertModel: AlertModel?
    @Published var inputAlertModel: AlertModel?
    // Enable/Disable buttons and gestures
    @Published var addPartItemEnabled: Bool = false
    @Published var editingEnabled: Bool = false
    @Published var previousButtonEnabled: Bool = false
    @Published var nextButtonEnabled: Bool = false
    @Published var longPressGestureEnabled: Bool = true

    // MARK: - Properties

    weak var editor: IINKEditor?
    var addTextBlockValue = ""
    private weak var delegate: MainViewControllerDisplayLogic?
    private var activePenModeEnabled: Bool = true
    private var selectedPosition: CGPoint?
    private var engineProvider: EngineProvider
    private var toolingWorker: ToolingWorkerLogic
    private (set) var editorWorker: EditorWorkerLogic

    init(delegate: MainViewControllerDisplayLogic?,
         engineProvider: EngineProvider,
         toolingWorker: ToolingWorkerLogic,
         editorWorker: EditorWorkerLogic) {
        self.engineProvider = engineProvider
        self.delegate = delegate
        self.toolingWorker = toolingWorker
        self.editorWorker = editorWorker
        super.init()
        self.editorWorker.delegate = self
    }

    func checkEngineProviderValidity() {
        if self.engineProvider.engine == nil {
            self.errorAlertModel = AlertModelHelper.createAlert(title: "Certificate Error",
                                                                message: self.engineProvider.engineErrorMessage,
                                                                exitAppWhenClosed: true)
        }
    }

    func openLastModifiedFileIfAny() -> Bool {
        guard let lastOpenedFile = FilesProvider.retrieveLastModifiedFile() else {
            self.delegate?.displayNewDocumentOptions(cancelEnabled: false)
            return false
        }
        self.openFile(file: lastOpenedFile, engineProvider: self.engineProvider)
        return true
    }

    // MARK: - Editor Tooling

    func selectTool(tool: IINKPointerTool) {
        do {
            try self.toolingWorker.selectTool(tool: tool, activePenModeEnabled: self.activePenModeEnabled)
            self.longPressGestureEnabled = self.longPressGestureActivationConditon()
        } catch {
            self.handleToolingError(error: error)
        }
    }

    func didChangeActivePenMode(activated: Bool) {
        self.activePenModeEnabled = activated
        self.longPressGestureEnabled = self.longPressGestureActivationConditon()
        do {
            try self.toolingWorker.didChangeActivePenMode(activated: self.activePenModeEnabled)
        } catch {
            self.handleToolingError(error: error)
        }
    }

    func didSelectStyle(style: ToolStyleModel) {
        do {
            try self.toolingWorker.didSelectStyle(style: style)
        } catch {
            self.handleToolingError(error: error)
        }
    }

    private func handleToolingError(error: Error) {
        guard let toolingError = error as? ToolingWorker.ToolingError else {
            return
        }
        self.errorAlertModel = AlertModelHelper.createAlertModel(with: toolingError)
    }

    private func longPressGestureActivationConditon() -> Bool {
        // Don't activate longpress gesture if ActivePen mode is off and tool is not hand or selector
        if  self.activePenModeEnabled == false,
           let currentTool = try? self.editor?.toolController.tool(forType: .pen),
           currentTool.value != .hand,
           currentTool.value != .toolSelector {
            return false
        }
        return true
    }

    // MARK: - Editor Business Logic

    func createNewPart(partType: SelectedPartTypeModel, engineProvider: EngineProvider) {
        do {
            try self.editorWorker.createNewPart(partType: partType, engineProvider: engineProvider)
        } catch {
            self.handleEditorError(error: error)
        }
    }

    func loadNextPart() {
        self.editorWorker.loadNextPart()
    }

    func loadPreviousPart() {
        self.editorWorker.loadPreviousPart()
    }

    func undo() {
        self.editorWorker.undo()
    }

    func redo() {
        self.editorWorker.redo()
    }

    func clear() {
        self.editorWorker.clear()
    }

    func convert(selection: (NSObjectProtocol & IINKIContentSelection)? = nil) {
        do {
            try self.editorWorker.convert(selection: selection)
        } catch {
            self.handleEditorError(error: error)
        }
    }

    func zoomIn() {
        do {
            try self.editorWorker.zoomIn()
        } catch {
            self.handleDefaultError(errorMessage: error.localizedDescription)
        }
    }

    func zoomOut() {
        do {
            try self.editorWorker.zoomOut()
        } catch {
            self.handleDefaultError(errorMessage: error.localizedDescription)
        }
    }

    func openFile(file: File, engineProvider: EngineProvider) {
        self.editorWorker.openFile(file: file, engineProvider: engineProvider)
    }

    func moreActions(barButtonIdem: UIBarButtonItem) {
        var actions: [ActionModel] = []
        let exportAction = ActionModel(actionText: "Export") { [weak self] action in
            self?.delegate?.displayExportOptions()
        }
        actions.append(exportAction)
        let resetViewAction = ActionModel(actionText: "Reset View") { [weak self] action in
            self?.editorWorker.resetView()
            // Ask DisplayViewController to refresh its view
            NotificationCenter.default.post(name: DisplayViewController.refreshNotification, object: nil)
        }
        actions.append(resetViewAction)
        let newAction = ActionModel(actionText: "New") { [weak self] action in
            try? self?.editorWorker.save()
            self?.delegate?.displayNewDocumentOptions(cancelEnabled: true)
        }
        actions.append(newAction)
        let openAction = ActionModel(actionText: "Open") { [weak self] action in
            try? self?.editorWorker.save()
            self?.delegate?.displayOpenDocumentOptions()
        }
        actions.append(openAction)
        let saveAction = ActionModel(actionText: "Save") { [weak self] action in
            do {
                try self?.editorWorker.save()
            } catch {
                self?.handleDefaultError(errorMessage: error.localizedDescription)
            }
        }
        actions.append(saveAction)
        self.moreActionsAlertModel = AlertModel(title: "More actions", alertStyle: .actionSheet, actionModels: actions)
    }

    func handleLongPressGesture(state: UIGestureRecognizer.State,
                                position: CGPoint,
                                sourceView: UIView) {
        if state == .began, let editor = self.editor {
            var block: (NSObjectProtocol & IINKIContentSelection)? = editor.rootBlock
            if let selectionBlock = editor.hitSelection(position) {
                block = selectionBlock
            } else if let hitBlock = editor.hitBlock(position) {
                block = hitBlock
            }
            if let block = block {
                let sourceRect: CGRect = CGRect(x: position.x, y: position.y, width: 1, height: 1)
                self.createMoreMenu(with: block,
                                    position: position,
                                    sourceView: sourceView,
                                    sourceRect: sourceRect)
            }
        }
    }

    func addImageBlock(with image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1),
              let position = self.selectedPosition else {
            return
        }
        do {
            try self.editorWorker.addImageBlock(data: data, position: position)
        } catch {
            self.handleEditorError(error: error)
        }
    }

    func enableRawContentConversion() {
        self.editorWorker.enableRawContentConversion()
    }

    private func handleEditorError(error: Error) {
        guard let editorError = error as? EditorWorker.EditorError else {
            return
        }
        self.errorAlertModel = AlertModelHelper.createAlertModel(with: editorError)
    }

    private func createMoreMenu(with content: NSObjectProtocol & IINKIContentSelection,
                                position: CGPoint,
                                sourceView: UIView?,
                                sourceRect: CGRect) {
        guard let editor = self.editor else {
            return
        }
        self.selectedPosition = position
        var actionModels: [ActionModel] = []
        let actions = ContextualActionsHelper.availableActions(forContent: content, editor: editor)
        // Fill actionModels
        if actions.contains(.addBlock) {
            for type in editor.supportedAddBlockTypes {
                if type == "Text" {
                    let actionTitle = "Add Text"
                    let action = ActionModel(actionText: actionTitle) { [weak self] action in
                        let inputAction = ActionModel(actionText: actionTitle) { [weak self] action in
                            do {
                                try self?.editorWorker.addTextBlock(position: position, data: self?.addTextBlockValue ?? "")
                            } catch {
                                self?.handleDefaultError(errorMessage: error.localizedDescription)
                            }
                        }
                        self?.inputAlertModel = AlertModel(title: actionTitle,
                                                           actionModels: [inputAction])
                    }
                    actionModels.append(action)
                } else if type == "Image" {
                    let action = ActionModel(actionText: "Add Image") { [weak self] action in
                        self?.delegate?.displayImagePicker()
                    }
                    actionModels.append(action)
                } else {
                    let addTitle = String(format: "Add %@", type)
                    let action = ActionModel(actionText: addTitle) { [weak self] action in
                        do {
                            try self?.editorWorker.addBlock(position: position, type: type)
                        } catch {
                            self?.handleDefaultError(errorMessage: error.localizedDescription)
                        }
                    }
                    actionModels.append(action)
                }
            }
        }
        if actions.contains(.remove) {
            let action = ActionModel(actionText: "Remove") { [weak self] action in
                do {
                    try self?.editorWorker.erase(selection: content)
                } catch {
                    self?.handleDefaultError(errorMessage: error.localizedDescription)
                }
            }
            actionModels.append(action)
        }
        if actions.contains(.copy) {
            let action = ActionModel(actionText: "Copy") { [weak self] action in
                do {
                    try self?.editorWorker.copy(selection: content)
                } catch {
                    self?.handleDefaultError(errorMessage: error.localizedDescription)
                }
            }
            actionModels.append(action)
        }
        if actions.contains(.paste) {
            let action = ActionModel(actionText: "Paste") { [weak self] action in
                do {
                    try self?.editorWorker.paste(at: position)
                } catch {
                    self?.handleDefaultError(errorMessage: error.localizedDescription)
                }
            }
            actionModels.append(action)
        }
        if actions.contains(.exportData) {
            let action = ActionModel(actionText: "Export") { [weak self] action in
                self?.delegate?.displayExportOptions()
            }
            actionModels.append(action)
        }
        if actions.contains(.convert) {
            let action = ActionModel(actionText: "Convert") { [weak self] action in
                self?.convert(selection: content)
            }
            actionModels.append(action)
        }
        if actions.contains(.formatText) {
            let action = ActionModel(actionText: "Format Text") { [weak self] action in
                self?.createFormatTextMenu(selection: content,
                                           sourceView: sourceView,
                                           sourceRect: sourceRect)
            }
            actionModels.append(action)
        }

        if actionModels.count > 0 {
            self.menuAlertModel = AlertModel(alertStyle: .actionSheet,
                                             actionModels: actionModels,
                                             sourceView: sourceView,
                                             sourceRect: sourceRect)
        }
    }

    private func createFormatTextMenu(selection: NSObjectProtocol & IINKIContentSelection,
                                      sourceView: UIView?,
                                      sourceRect: CGRect) {
        DispatchQueue.main.async {
            guard let editor = self.editor else {
                return
            }
            let formats = editor.supportedTextFormats(forSelection: selection)
            var actionModels: [ActionModel] = []
            for format in formats {
                let action = ActionModel(actionText: TextFormatHelper.name(for: format.value)) { [weak self] action in
                    do {
                        try self?.editorWorker.set(textFormat: format.value, selection: selection)
                    } catch {
                        self?.handleDefaultError(errorMessage: error.localizedDescription)
                    }
                }
                actionModels.append(action)
            }
            if actionModels.count > 0 {
                self.menuAlertModel = AlertModel(alertStyle: .actionSheet,
                                             actionModels: actionModels,
                                             sourceView: sourceView,
                                             sourceRect: sourceRect)
            }
        }
    }

    private func handleDefaultError(errorMessage: String) {
        self.errorAlertModel = AlertModelHelper.createDefaultErrorAlert(message: errorMessage,
                                                                        exitAppWhenClosed: false)
    }
}

// MARK: - Delegates

extension MainViewModel: EditorDelegate {

    func didCreateEditor(editor: IINKEditor?) {
        self.editor = editor
        self.toolingWorker.editor = editor
        self.editorWorker.editor = editor
    }
}

extension MainViewModel: SmartGuideViewControllerDelegate {

    func smartGuideViewController(_ smartGuideViewController: SmartGuideViewController!,
                                  didTapOnMoreButton moreButton: UIButton!,
                                  for block: IINKContentBlock!) {
        self.createMoreMenu(with: block,
                            position: CGPoint.zero,
                            sourceView: moreButton,
                            sourceRect: moreButton.bounds)
    }
}

extension MainViewModel: MainViewModelEditorLogic {

    func didCreatePackage(fileName: String) {
        self.addPartItemEnabled = true
    }

    func didLoadPart(title: String, index: Int, partCount: Int) {
        // Enable buttons
        self.editingEnabled = true
        self.previousButtonEnabled = index > 0
        self.nextButtonEnabled = index < partCount - 1
        // Set title
        self.title = title
    }

    func didUnloadPart() {
        self.title = ""
        self.editingEnabled = false
    }

    func didOpenFile() {
        self.addPartItemEnabled = true
        self.previousButtonEnabled = false
    }
}
