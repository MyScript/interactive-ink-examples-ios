// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// This class is the ViewModel of the ExportTableViewController. It handles all its business logic.

class ExportViewModel {

    // MARK: Published Properties

    @Published var model:ExportModel?

    // MARK: Properties

    private weak var editor:IINKEditor?
    weak var delegate:ExportTableViewControllerDisplayLogic?
    private var fileName:String = ""

    // MARK: Init

    init(editor:IINKEditor?) {
        self.editor = editor
    }

    // MARK: Business Logic

    func loadData() {
        if let editor = editor, let rootBlock = editor.rootBlock {
            let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            let mimetypes: [IINKMimeTypeValue] = editor.supportedExportMimeTypes(forSelection: rootBlock)
            self.model = ExportModel(title: "Export",
                                     description: "The exported files will be in the document directory",
                                     mimeTypes: mimetypes,
                                     cancelBarButtonItem: cancelBarButtonItem)
        }
    }

    func export(indexOfMimeTypeSelected: Int) {
        if self.model?.mimeTypes.count ?? 0 > indexOfMimeTypeSelected,
           let mimeTypeValue = self.model?.mimeTypes[indexOfMimeTypeSelected] {
            do {
                let imageLoader = ImageLoader()
                let imagePainter = ImagePainter(imageLoader: imageLoader)
                let part = self.editor?.part?.identifier ?? ""
                let type = self.editor?.part?.type ?? ""
                var extensionFormat = IINKMimeTypeValue.iinkMimeTypeGetFileExtensions(mimeTypeValue.value)
                extensionFormat = extensionFormat.components(separatedBy: ",").first ?? ""
                self.fileName = String(format: "%@-%@%@", part, type, extensionFormat)
                let path = FileManager.default.pathForFileInDocumentDirectory(fileName: fileName)
                self.editor?.waitForIdle() // Waits until part modification operations are over.
                try self.editor?.export(selection: self.editor?.rootBlock,
                                        destinationFile: path,
                                        mimeType: mimeTypeValue.value,
                                        imagePainter: imagePainter)
                let message = String(format: "The content has been exported to %@ successfuly", self.fileName)
                let alertModel = AlertModelHelper.createAlert(title: "Export succeeded", message: message, exitAppWhenClosed: false)
                self.delegate?.exportFinishedWithResult(result: alertModel)
            } catch {
                self.handleExportError()
            }
        } else {
            self.handleExportError()
        }
    }

    private func handleExportError() {
        var errorText = ""
        if self.fileName.isEmpty {
            errorText = "Failed to export the content"
        } else {
            errorText = String(format: "Failed to export the content to %@", self.fileName)
        }
        let alertModel = AlertModelHelper.createAlert(title: "Export failed", message: errorText, exitAppWhenClosed: false)
        self.delegate?.exportFinishedWithResult(result: alertModel)
    }

    @objc private func cancel() {
        self.delegate?.cancel()
    }
}
