// Copyright @ MyScript. All rights reserved.

import Foundation

/**
 * Protocol describing the EditorWorker interface
 */

protocol EditorWorkerLogic {

    mutating func createNewPart(partTypeCreationModel: PartTypeCreationModel, engineProvider: EngineProvider) throws
    func loadNextPart()
    func loadPreviousPart()
    func undo()
    func redo()
    func zoomIn() throws
    func zoomOut() throws
    func clear() throws
    func convert(selection: (NSObjectProtocol & IINKIContentSelection)?) throws
    mutating func openFile(file: File, engineProvider: EngineProvider)
    func resetView()
    func save() throws
    func addImageBlock(data: Data, position: CGPoint) throws
    func configureEditor()
    func enableCaptureStrokePrediction()
    func erase(selection: NSObjectProtocol & IINKIContentSelection) throws
    func copy(selection: NSObjectProtocol & IINKIContentSelection) throws
    func paste(at position: CGPoint) throws
    func set(textFormat: IINKTextFormat, selection: NSObjectProtocol & IINKIContentSelection) throws
    func addTextBlock(position: CGPoint, data: String) throws
    func addBlock(position: CGPoint, type: String) throws
    func unloadPart()

    var editor: IINKEditor? { get set }
    var delegate: MainViewModelEditorLogic? { get set }
}

/**
 * This worker is in charge of all the logic around the IINK editor
 */

class EditorWorker: EditorWorkerLogic {

    enum EditorError: Error {
        case partCreationFailed
        case convertFailed
        case addImageFailed
        case clearFailed
    }

    weak var delegate: MainViewModelEditorLogic?
    weak var editor: IINKEditor?
    var currentPackage: IINKContentPackage?
    private var currentFileName: String = ""

    func createNewPart(partTypeCreationModel: PartTypeCreationModel, engineProvider: EngineProvider) throws {
        // Create a new pacakage if requested
        if partTypeCreationModel.onNewPackage {
            do {
                self.unloadPart()
                try self.createPackage(engineProvider: engineProvider)
            } catch {
                throw EditorError.partCreationFailed
            }
        }
        // Create a new part to the package
        do {
            if var part: IINKContentPart = try self.currentPackage?.createPart(with: partTypeCreationModel.partType.partType) {
                // Set its configuration profile
                self.setPartConfigurationProfile(part: &part, configuration: partTypeCreationModel.partType.configuration)
                // Then load it
                self.loadPart(part: part)
            }
        } catch {
            print("Error while creating part : " + error.localizedDescription)
            throw EditorError.partCreationFailed
        }
    }

    func loadNextPart() {
        if let editor = self.editor,
           let part = editor.part,
           let currentPackage = self.currentPackage {
            let partCount: Int = currentPackage.partCount()
            let currentIndex: Int = currentPackage.index(of: part)
            if currentIndex < partCount - 1,
               let nextPart = try? currentPackage.part(at: currentIndex + 1) {
                self.loadPart(part: nextPart)
            }
        }
    }

    func loadPreviousPart() {
        if let editor = self.editor,
           let part = editor.part,
           let currentPackage = self.currentPackage {
            let currentIndex: Int = currentPackage.index(of: part)
            if currentIndex > 0,
               let nextPart = try? currentPackage.part(at: currentIndex - 1) {
                self.loadPart(part: nextPart)
            }
        }
    }

    func undo() {
        self.editor?.undo()
    }

    func redo() {
        self.editor?.redo()
    }

    func clear() throws {
        do {
            try self.editor?.clear()
        } catch {
            print("Error while clearing page : " + error.localizedDescription)
            throw EditorError.clearFailed
        }
    }

    func convert(selection: (NSObjectProtocol & IINKIContentSelection)? = nil) throws {
        do {
            if let supportedTargetStates = self.editor?.supportedTargetConversionState(forSelection: selection) {
                if !supportedTargetStates.isEmpty {
                    try self.editor?.convert(selection: selection, targetState: supportedTargetStates[0].value)
                }
            }
        } catch {
            print("Error while converting : " + error.localizedDescription)
            throw EditorError.convertFailed
        }
    }

    func zoomIn() throws {
        do {
            try self.editor?.renderer.zoom(110/100)
        } catch {
            throw error
        }
        // Ask DisplayViewController to refresh its view
        NotificationCenter.default.post(name: DisplayViewController.refreshNotification, object: nil)
    }

    func zoomOut() throws {
        do {
            try self.editor?.renderer.zoom(100/110)
        } catch {
            throw error
        }
        // Ask DisplayViewController to refresh its view
        NotificationCenter.default.post(name: DisplayViewController.refreshNotification, object: nil)
    }

    func openFile(file: File, engineProvider: EngineProvider) {
        if let engine: IINKEngine = engineProvider.engine {
            let filePath = FileManager.default.pathForFileInIinkDirectory(fileName: file.fileName) as NSString
            self.unloadPart()
            self.currentFileName = filePath.lastPathComponent
            self.currentPackage = try? engine.openPackage(filePath.decomposedStringWithCanonicalMapping)
            if let currentPackage = self.currentPackage,
               let part: IINKContentPart = try? currentPackage.part(at: 0) {
                self.loadPart(part: part)
            }
            self.delegate?.didOpenFile()
        }
    }

    func resetView() {
        self.editor?.renderer.viewScale = 1
        self.editor?.renderer.viewOffset = CGPoint.zero
    }

    func save() throws {
        if let currentPackage = self.currentPackage {
            do {
                try currentPackage.save()
            } catch {
                throw error
            }
        }
    }

    func addTextBlock(position: CGPoint, data: String) throws {
        do {
            try self.editor?.addBlock(position: position,
                                 type: "Text",
                                 mimeType: .text,
                                 data: data)
        } catch {
            throw error
        }
    }

    func addBlock(position: CGPoint, type: String) throws {
        do {
            try self.editor?.addBlock(at: position,
                                 type: type)
        } catch {
            throw error
        }
    }

    func addImageBlock(data: Data, position: CGPoint) throws {
        let fileName = String(format: "%f.jpg", Date.timeIntervalSinceReferenceDate)
        let filePath = FileManager.default.pathForFileInTmpDirectory(fileName: fileName)
        do {
            let nsData: NSData = NSData(data: data)
            try nsData.write(toFile: filePath, options: .atomicWrite)
            try self.editor?.addImage(position: position, file: filePath, mimeType: .JPEG)
        } catch {
            print("An error occurred with the image: \(error)")
            throw EditorError.addImageFailed
        }
    }

    func configureEditor() {
        guard let engine = EngineProvider.sharedInstance.engine else {
            return
        }
        // Configure multithreading for text recognition
        try? engine.configuration.set(number: 1, forKey: "max-recognition-thread-count");
    }

    func enableCaptureStrokePrediction() {
        guard let engine = EngineProvider.sharedInstance.engine else {
            return
        }

        let MinPredictionDurationMs: Int = 16 // 1 frame @60Hz, 2 frames @120Hz
        var frameTimeMs = Int(round(1000.0 / Double(UIScreen.main.maximumFramesPerSecond)))
        frameTimeMs = max(frameTimeMs, MinPredictionDurationMs)

        try? engine.configuration.set(number: Double(frameTimeMs), forKey: "renderer.prediction.duration");
        try? engine.configuration.set(boolean: true, forKey: "renderer.prediction.enable");
    }

    func copy(selection: NSObjectProtocol & IINKIContentSelection) throws {
        do {
            try self.editor?.copy(selection)
        } catch {
            throw error
        }
    }

    func erase(selection: NSObjectProtocol & IINKIContentSelection) throws {
        do {
            try self.editor?.erase(selection)
        } catch {
            throw error
        }
    }

    func paste(at position: CGPoint) throws {
        do {
            try self.editor?.paste(at: position)
        } catch {
            throw error
        }
    }

    func set(textFormat: IINKTextFormat, selection: NSObjectProtocol & IINKIContentSelection) throws {
        do {
            try self.editor?.set(textFormat: textFormat, selection: selection)
        } catch {
            throw error
        }
    }

    func unloadPart() {
        self.currentPackage = nil
        self.editor?.part = nil
        self.delegate?.didUnloadPart()
    }

    /**
     * Creates a new package, using name "File%d.iink"
     * number for which the resulting file does not exist.
     */
    private func createPackage(engineProvider: EngineProvider) throws {
        guard let engine = engineProvider.engine else {
            return
        }
        let existingIInkFiles = FilesProvider.iinkFilesFromIInkDirectory()
        let fileNames: [String] = existingIInkFiles.map({ $0.fileName })
        var index: Int = 0
        var newName = ""
        var newTempName = ""
        repeat {
            index+=1
            newName = String(format: "File%d.iink", index)
            newTempName = String(format: "File%d.iink-files", index)
        } while fileNames.contains(newName) || fileNames.contains(newTempName)
        do {
            let fullPath = FileManager.default.pathForFileInIinkDirectory(fileName: newName)
            self.currentPackage = try engine.createPackage(fullPath.decomposedStringWithCanonicalMapping)
            self.currentFileName = newName
            self.delegate?.didCreatePackage(fileName: newName)
        } catch {
            print("Error while creating package : " + error.localizedDescription)
            throw error
        }
    }

    private func setPartConfigurationProfile( part: inout IINKContentPart, configuration: String) {
        guard let partMetaData = part.metadata else {
            return
        }
        try? partMetaData.set(string: configuration, forKey: ConfigurationsProvider.configProfileMetadataKey)
        part.metadata = partMetaData
    }

    private func loadPart(part: IINKContentPart) {
        // Reset viewing parameters
        self.editor?.renderer.viewScale = 1
        self.editor?.renderer.viewOffset = CGPoint.zero
        self.editor?.configuration.reset()
        // Retrieve the configuration profile and inject it to the editor
        if let configurationJson = ConfigurationsProvider.configurationJson(from: part) {
            try? self.editor?.configuration.inject(configurationJson)
        }
        // Set part
        self.editor?.part = part
        // Inform delegate
        let partCount = self.currentPackage?.partCount() ?? 0
        let index: Int = self.currentPackage?.index(of: part) ?? 0
        let title = String(format: "%@ - %@", self.currentFileName, part.type)
        self.delegate?.didLoadPart(title: title, index: index, partCount: partCount)
    }
}
