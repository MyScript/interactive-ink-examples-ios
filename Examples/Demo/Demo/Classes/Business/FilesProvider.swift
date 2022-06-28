// Copyright @ MyScript. All rights reserved.

import Foundation

/// The FilesProvider is used to get and provide iink Files stored in the iink directory

struct FilesProvider {

    static func iinkFilesFromIInkDirectory() -> [File] {
        var result: [File] = [File]()
        let fileManager: FileManager = FileManager.default
        // Get the files in itunes folder
        do {
            result.append(contentsOf: try retrieveFiles(path: fileManager.iinkDirectory(), with: "iink"))
            result.append(contentsOf: try retrieveFiles(path: NSTemporaryDirectory(), with: "iink-files"))
        } catch {
            print ("Error while retrieving files: %@", error.localizedDescription)
        }
        return result
    }

    static private func retrieveFiles(path: String, with fileExtension: String) throws -> [File]  {
        var result: [File] = [File]()
        let fileManager: FileManager = FileManager.default
        let fileNames = try fileManager.contentsOfDirectory(atPath: path)
        for fileName in fileNames {
            let url = URL(fileURLWithPath: fileName)
            if url.pathExtension == fileExtension {
                let fullPath = URL(string: path)?.appendingPathComponent(fileName)
                let attributes: [FileAttributeKey : Any] = try fileManager.attributesOfItem(atPath: fullPath?.absoluteString ?? "")
                if let modificationDate: Date = attributes[.modificationDate] as? Date,
                   let fileSize: Float = attributes[.size] as? Float {
                    let file: File = File(fileName: fileName, modificationDate: modificationDate, fileSize: fileSize)
                    result.append(file)
                }
            }
        }
        return result
    }

    static func retrieveLastModifiedFile() -> File? {
        let files: [File] = iinkFilesFromIInkDirectory()
        guard files.count > 0 else {
            return nil
        }
        return files.sorted {$0.modificationDate > $1.modificationDate}[0]
    }
}
