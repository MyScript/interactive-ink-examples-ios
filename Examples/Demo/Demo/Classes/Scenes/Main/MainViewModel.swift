// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// This class is the ViewModel of the MainViewController. It handles all it's business logic.

class MainViewModel : NSObject {

    // MARK: Published Properties

    @Published var editorViewController:EditorViewController?
    @Published var title:String?
    @Published var inputMode:InputMode = .forcePen
    // Alerts
    @Published var errorAlertController:UIAlertController?
    @Published var menuAlertController:UIAlertController?
    @Published var moreActionsAlertController:UIAlertController?
    @Published var inputAlertController:UIAlertController?
    // Enable/Disable buttons
    @Published var addPartItemEnabled:Bool = false
    @Published var editionButtonsEnabled:Bool = false
    @Published var previousButtonEnabled:Bool = false
    @Published var nextButtonEnabled:Bool = false

    // MARK: Properties

    weak var editor:IINKEditor?
    var currentPackage:IINKContentPackage?
    private weak var delegate:MainViewControllerDisplayLogic?
    private var currentFileName:String = ""

    init(delegate:MainViewControllerDisplayLogic?) {
        self.delegate = delegate
    }

    func setupEditorController(engineProvider:EngineProvider) {
        let editorViewModel:EditorViewModel = EditorViewModel(engine: engineProvider.engine, inputMode: .forcePen, editorDelegate: self, smartGuideDelegate: self)
        self.editorViewController = EditorViewController(viewModel: editorViewModel)
        if engineProvider.engine == nil {
            createAlert(title: "Certificate Error", message: engineProvider.engineErrorMessage, exitAppWhenClosed: true)
        }
    }

    // MARK: Editor Business Logic

    func createNewPart(partType:SelectedPartTypeModel, engineProvider:EngineProvider) {
        // Create a new pacakage if requested
        if partType.onNewPackage {
            unloadPart()
            createPackage(engineProvider:engineProvider)
        }
        // Create a new part to the package
        do {
            if let part:IINKContentPart = try self.currentPackage?.createPart(partType.partType) {
                // Then load it
                self.loadPart(part: part)
            }
        } catch {
            self.handlePartCreationError(error: error)
        }
    }

    func undo() {
        self.editor?.undo()
    }

    func redo() {
        self.editor?.redo()
    }

    func clear() {
        self.editor?.clear()
    }

    func updateInputMode(newInputModeIndex:Int) {
        guard let inputMode = InputMode(rawValue: newInputModeIndex) else { return }
        self.inputMode = inputMode
        self.editorViewController?.updateInputMode(newInputMode: inputMode)
    }

    func loadNextPart() {
        if let editor = self.editor,
           let part = editor.part,
           let currentPackage = self.currentPackage {
            let partCount:Int = currentPackage.partCount()
            let currentIndex:Int = currentPackage.index(of: part)
            if currentIndex < partCount - 1,
               let nextPart = try? currentPackage.getPartAt(currentIndex + 1) {
                self.loadPart(part: nextPart)
            }
        }
    }

    func loadPreviousPart() {
        if let editor = self.editor,
           let part = editor.part,
           let currentPackage = self.currentPackage {
            let currentIndex:Int = currentPackage.index(of: part)
            if currentIndex > 0,
               let nextPart = try? currentPackage.getPartAt(currentIndex - 1) {
                self.loadPart(part: nextPart)
            }
        }
    }

    func convert() {
        do {
            if let supportedTargetStates = self.editor?.getSupportedTargetConversionState(nil) {
                try self.editor?.convert(nil, targetState: supportedTargetStates[0].value)
            }
        } catch {
            createAlert(title: "Error", message: "An error occured during the convertion")
            print("Error while converting : " + error.localizedDescription)
        }
    }

    func openFile(file:File, engineProvider: EngineProvider) {
        if let engine:IINKEngine = engineProvider.engine {
            let filePath:NSString = FileManager.default.pathForFileInIinkDirectory(fileName: file.fileName) as NSString
            self.unloadPart()
            self.currentFileName = filePath.lastPathComponent
            self.addPartItemEnabled = true
            self.currentPackage = try? engine.openPackage(filePath.decomposedStringWithCanonicalMapping)
            if let currentPackage = self.currentPackage,
               let part:IINKContentPart = try? currentPackage.getPartAt(0) {
                self.loadPart(part:part)
            }
            self.previousButtonEnabled = false
        }
    }

    func handleExportResult(result:ExportResultModel) {
        self.createAlert(title: result.title, message: result.message, exitAppWhenClosed: false)
    }

    func moreActions(barButtonIdem:UIBarButtonItem) {
        let moreAlertController:UIAlertController = UIAlertController(title: "More actions", message: nil, preferredStyle: .actionSheet)
        let exportAction:UIAlertAction = UIAlertAction(title: "Export", style: .default) { action in
            self.delegate?.displayExportOptions()
        }
        moreAlertController.addAction(exportAction)
        let zoomInAction:UIAlertAction = UIAlertAction(title: "Zoom in", style: .default) { [weak self] action in
            _ = try? self?.editor?.renderer.zoom(110/100)
            // Ask DisplayViewController to refresh it's view
            NotificationCenter.default.post(name: DisplayViewController.refreshNotification, object: nil)
        }
        moreAlertController.addAction(zoomInAction)
        let zoomOutAction:UIAlertAction = UIAlertAction(title: "Zoom out", style: .default) { [weak self] action in
            _ = try? self?.editor?.renderer.zoom(100/110)
            // Ask DisplayViewController to refresh it's view
            NotificationCenter.default.post(name: DisplayViewController.refreshNotification, object: nil)
        }
        moreAlertController.addAction(zoomOutAction)
        let resetViewAction:UIAlertAction = UIAlertAction(title: "Reset View", style: .default) { [weak self] action in
            self?.editor?.renderer.viewScale = 1
            self?.editor?.renderer.viewOffset = CGPoint.zero
            // Ask DisplayViewController to refresh it's view
            NotificationCenter.default.post(name: DisplayViewController.refreshNotification, object: nil)
        }
        moreAlertController.addAction(resetViewAction)
        let newAction:UIAlertAction = UIAlertAction(title: "New", style: .default) { [weak self] action in
            if let currentPackage = self?.currentPackage {
                _ = try? currentPackage.save()
            }
            self?.delegate?.displayNewDocumentOptions()
        }
        moreAlertController.addAction(newAction)
        let openAction:UIAlertAction = UIAlertAction(title: "Open", style: .default) { [weak self] action in
            if let currentPackage = self?.currentPackage {
                _ = try? currentPackage.save()
            }
            self?.delegate?.displayOpenDocumentOptions()
        }
        moreAlertController.addAction(openAction)
        let saveAction:UIAlertAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let currentPackage = self?.currentPackage {
                _ = try? currentPackage.save()
            }
        }
        moreAlertController.addAction(saveAction)
        if let popover:UIPopoverPresentationController = moreAlertController.popoverPresentationController {
            popover.permittedArrowDirections = .up
            popover.barButtonItem = barButtonIdem
            self.moreActionsAlertController = moreAlertController
        } else {
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            moreAlertController.addAction(cancelAction)
            self.moreActionsAlertController = moreAlertController
        }
    }

    func handleLongPressGesture(state:UIGestureRecognizer.State, position:CGPoint, sourceView:UIView) {
        if state == .began,
           let editor = self.editor {
            let block:IINKContentBlock? = editor.hitBlock(position) ?? editor.rootBlock
            if let block = block {
                let sourceRect:CGRect = CGRect(x: position.x, y: position.y, width: 1, height: 1)
                self.createMoreMenuWith(block: block, position: position, sourceView: sourceView, sourceRect: sourceRect)
            }
        }
    }

    private func createMoreMenuWith(block:IINKContentBlock, position:CGPoint, sourceView:UIView, sourceRect:CGRect) {
        guard let editor = self.editor,
              let rootBlock = editor.rootBlock else { return }
        let block:IINKContentBlock = block.type == "Container" ? rootBlock : block
        let supportedStates = editor.getSupportedTargetConversionState(block)
        let hasTypes:Bool = editor.supportedAddBlockTypes.count > 0
        let hasStates:Bool = supportedStates.count > 0
        let isRoot:Bool = block.identifier == rootBlock.identifier
        let isEmpty:Bool = editor.isEmpty(block)
        let onTextDocument:Bool = editor.part?.type == "Text Document"
        // determine which actions to diplay
        let displayConvert:Bool = hasStates && !isEmpty
        let displayAddBlock:Bool = hasTypes && isRoot
        let displayRemove:Bool = !isRoot
        let displayCopy:Bool = !onTextDocument || !isRoot
        let displayPaste:Bool = isRoot
        let menu:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Only on root block of a Text Document
        if displayAddBlock {
            for type in editor.supportedAddBlockTypes {
                if type == "Text" {
                    let action:UIAlertAction = UIAlertAction(title: "Add Text", style: .default) { [weak self] action in
                        let input:UIAlertController = UIAlertController(title: "Add Text", message: nil, preferredStyle: .alert)
                        input.addTextField(configurationHandler: nil)
                        let add:UIAlertAction = UIAlertAction(title: "Add Text", style: .default) { action in
                            _ = try? editor.addBlock(position, type: "Text", mimeType: .text, data: input.textFields?[0].text ?? "")
                        }
                        input.addAction(add)
                        self?.inputAlertController = input
                    }
                    menu.addAction(action)
                } else {
                    let addTitle:String = String(format: "Add %@", type)
                    let action:UIAlertAction = UIAlertAction(title: addTitle, style: .default) { action in
                        _ = try? editor.addBlock(position, type: type)
                    }
                    menu.addAction(action)
                }
            }
        }
        // Only if not on root block
        if displayRemove {
            let action:UIAlertAction = UIAlertAction(title: "Remove", style: .default) { action in
                _ = try? editor.remove(block)
            }
            menu.addAction(action)
        }
        // Only on a Text Document if not empty
        if displayConvert {
            let action:UIAlertAction = UIAlertAction(title: "Convert", style: .default) { action in
                _ = try? editor.convert(block, targetState: supportedStates[0].value)
            }
            menu.addAction(action)
        }
        // Only if not a Text Document or if not on root block
        if displayCopy {
            let action:UIAlertAction = UIAlertAction(title: "Copy", style: .default) { action in
                _ = try? editor.copy(block)
            }
            menu.addAction(action)
        }
        // Only if on root block
        if displayPaste {
            let action:UIAlertAction = UIAlertAction(title: "Paste", style: .default) { action in
                _ = try? editor.paste(position)
            }
            menu.addAction(action)
        }
        if menu.actions.count > 0 {
            if let popover:UIPopoverPresentationController = menu.popoverPresentationController {
                popover.sourceView = sourceView
                popover.sourceRect = sourceRect
            } else {
                let cancel:UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
                menu.addAction(cancel)
            }
            self.menuAlertController = menu
        }
    }

    private func unloadPart() {
        self.currentPackage = nil
        self.editor?.part = nil
        self.title = ""
    }

    /**
     * Creates a new package, using name "File%zd.iink" where "%@" is the smallest
     * number for which the resulting file does not exist.
     */
    private func createPackage(engineProvider:EngineProvider) {
        guard let engine = engineProvider.engine else {
            createAlert(title: "Certificate error", message: engineProvider.engineErrorMessage)
            return
        }
        let existingIInkFiles = FilesProvider.iinkFilesFromIInkDirectory()
        let fileNames:[String] = existingIInkFiles.map({ $0.fileName })
        var index:Int = 0
        var newName:String = ""
        var newTempName:String = ""
        repeat {
            index+=1
            newName = String(format: "File%d.iink", index)
            newTempName = String(format: "File%d.iink-files", index)
        } while fileNames.contains(newName) || fileNames.contains(newTempName)
        do {
            let fullPath = FileManager.default.pathForFileInIinkDirectory(fileName: newName)
            self.currentPackage = try engine.createPackage(fullPath.decomposedStringWithCanonicalMapping)
            self.currentFileName = newName
            self.addPartItemEnabled = true
        } catch {
            print(error)
            self.handlePartCreationError(error: error)
        }
    }

    private func loadPart(part:IINKContentPart) {
        // Reset viewing parameters
        self.editor?.renderer.viewScale = 1
        self.editor?.renderer.viewOffset = CGPoint.zero
        // Set part
        self.editor?.part = part
        // Enable buttons
        self.editionButtonsEnabled = true
        let partCount = self.currentPackage?.partCount() ?? 0
        let index:Int = self.currentPackage?.index(of:part) ?? 0
        self.previousButtonEnabled = index > 0
        self.nextButtonEnabled = index < partCount - 1
        // Set title
        self.title = String(format: "%@ - %@", self.currentFileName, part.type)
    }

    // MARK: UI Logic

    private func createAlert(title:String, message: String, exitAppWhenClosed:Bool = true) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if exitAppWhenClosed {
                exit(1)
            }
        }))
        self.errorAlertController = alert
    }

    private func handlePartCreationError(error:Error) {
        createAlert(title: "Error", message: "An error occured during the page creation")
        print("Error while creating package : " + error.localizedDescription)
    }

    func setEditorViewSize(bounds:CGRect) {
        self.editorViewController?.view.frame = bounds
    }
}

extension MainViewModel : EditorDelegate {

    func didCreateEditor(editor: IINKEditor?) {
        self.editor = editor
    }
}

extension MainViewModel : SmartGuideViewControllerDelegate {

    func smartGuideViewController(_ smartGuideViewController: SmartGuideViewController!, didTapOnMoreButton moreButton: UIButton!, for block: IINKContentBlock!) {
        self.createMoreMenuWith(block: block, position: CGPoint.zero, sourceView: moreButton, sourceRect:moreButton.bounds)
    }
}
