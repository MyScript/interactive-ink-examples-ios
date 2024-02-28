// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

enum PackagePartType {
    case textDocument
    case diagram
    case drawing
    case math
    case rawContent
    case text

    func getName() -> String {
        switch self {
            case .textDocument :
                return "Text Document"
            case .diagram :
                return "Diagram"
            case .drawing :
                return "Drawing"
            case .math :
                return "Math"
            case .text :
                return "Text"
            case .rawContent:
                return "Raw Content"
        }
    }
}

/// This class is the ViewModel of the HomeViewController. It handles all its business logic.

class HomeViewModel {

    // MARK: Published Properties

    @Published var model: HomeModel?
    @Published var alert: UIAlertController?

    // MARK: Properties

    var defaultPackageName: String = "New"
    var defaultpackageType: String = PackagePartType.textDocument.getName() /* Options are : "Diagram", "Drawing", "Math", "Raw Content", "Text Document", "Text" */
    weak var editor: IINKEditor?

    func setupModel(engineProvider: EngineProvider) {
        let model = HomeModel()
        // We want the Pen mode for this GetStarted sample code. It lets the user use either its mouse or fingers to draw.
        // If you have got an iPad Pro with an Apple Pencil, please set this value to InputModeAuto for a better experience.
        let editorViewModel:EditorViewModel = EditorViewModel(engine: engineProvider.engine, inputMode: .forcePen, editorDelegate: self, smartGuideDelegate: nil)
        model.editorViewController = EditorViewController(viewModel: editorViewModel)
        // create default Package for our GetStarted content
        model.title = "Type: " + self.defaultpackageType
        self.model = model
        self.createDefaultPackage(packageName: self.defaultPackageName, packageType: self.defaultpackageType, engineProvider: engineProvider)
    }

    // MARK: UI Logic

    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            exit(1)
        }))
        self.alert = alert
    }

    func setEditorViewSize(bounds:CGRect) {
        self.model?.editorViewController?.view.frame = bounds
    }

    // MARK: Editor Business Logic

    private func createDefaultPackage(packageName: String, packageType: String, engineProvider: EngineProvider) {
        guard let engine = engineProvider.engine else {
            createAlert(title: "Certificate error", message: engineProvider.engineErrorMessage)
            return
        }
        do {
            var resultPackage: IINKContentPackage?
            let fullPath = FileManager.default.pathForFileInDocumentDirectory(fileName: packageName) + ".iink"
            resultPackage = try engine.createPackage(fullPath.decomposedStringWithCanonicalMapping)
            // Add a blank page type Text Document
            try resultPackage?.createPart(with: packageType)
            if let package = resultPackage {
                try self.editor?.part = package.part(at: 0)
            }
        } catch {
            createAlert(title: "Error", message: "An error occurred during the page creation")
            print("Error while creating package : " + error.localizedDescription)
        }
    }

    // MARK: Actions

    func clear() {
        self.editor?.clear()
    }

    func undo() {
        self.editor?.undo()
    }

    func redo() {
        self.editor?.redo()
    }

    func convert() {
        do {
            if let supportedTargetStates = self.editor?.supportedTargetConversionState(forSelection: nil) {
                if !supportedTargetStates.isEmpty {
                    try self.editor?.convert(selection: nil, targetState: supportedTargetStates[0].value)
                }
            }
        } catch {
            createAlert(title: "Error", message: "An error occurred during the convertion")
            print("Error while converting : " + error.localizedDescription)
        }
    }

    func updateInputMode(newInputMode: InputMode) {
        self.model?.editorViewController?.updateInputMode(newInputMode: newInputMode)
    }

}

extension HomeViewModel: EditorDelegate {

    func didCreateEditor(editor: IINKEditor?) {
        self.editor = editor
    }
}
