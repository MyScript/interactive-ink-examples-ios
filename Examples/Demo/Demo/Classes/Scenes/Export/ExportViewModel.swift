// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// This class is the ViewModel of the ExportTableViewController. It handles all it's business logic.

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
        if let editor = editor {
            let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            let mimetypes:[IINKMimeTypeValue] = editor.getSupportedExportMimeTypes(editor.rootBlock)
            self.model = ExportModel(title: "Export", description: "The exported files will be in the document directory", mimeTypes: mimetypes, cancelBarButtonItem: cancelBarButtonItem)
        }
    }

    func export(indexOfMimeTypeSelected:Int) {
        if self.model?.mimeTypes.count ?? 0 > indexOfMimeTypeSelected,
           let mimeTypeValue = self.model?.mimeTypes[indexOfMimeTypeSelected] {
            do {
                let imageLoader:ImageLoader = ImageLoader()
                let imageDrawer:ImageDrawer = ImageDrawer(imageLoader: imageLoader)
                let part:String = self.editor?.part?.identifier ?? ""
                let type:String = self.editor?.part?.type ?? ""
                var extensionFormat:String = IINKMimeTypeValue.iinkMimeTypeGetFileExtensions(mimeTypeValue.value)
                extensionFormat = extensionFormat.components(separatedBy: ",").first ?? ""
                self.fileName = String(format: "%@-%@%@", part, type, extensionFormat)
                let path:String = FileManager.default.pathForFileInDocumentDirectory(fileName: fileName)
                self.editor?.waitForIdle() // Waits until part modification operations are over.
                try self.editor?.export_(self.editor?.rootBlock, toFile: path, mimeType: mimeTypeValue.value, imageDrawer: imageDrawer)
                let result:ExportResultModel = ExportResultModel(title: "Export succeeded", message: String(format: "The content has been exported to %@ successfuly", self.fileName))
                self.delegate?.exportFinishedWithResult(result: result)
            } catch {
                self.handleExportError()
            }
        } else {
            self.handleExportError()
        }
    }

    private func handleExportError() {
        var errorText:String = ""
        if self.fileName.isEmpty {
            errorText = "Failed to export the content"
        } else {
            errorText = String(format: "Failed to export the content to %@", self.fileName)
        }
        let result:ExportResultModel = ExportResultModel(title: "Export failed", message: errorText)
        self.delegate?.exportFinishedWithResult(result: result)
    }

    @objc private func cancel() {
        self.delegate?.cancel()
    }
}
