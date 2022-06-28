// Copyright @ MyScript. All rights reserved.

import Foundation

/// Files Utils

extension FileManager {

    func createIinkDirectory() {
        let iinkFilesDirectory:String = iinkDirectory()
        if !self.fileExists(atPath: iinkFilesDirectory) {
            do {
                try self.createDirectory(atPath: iinkFilesDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch { // Error not catched for now
                print(String(format: "Cannot create dir %@, error %@", iinkFilesDirectory, error.localizedDescription))
            }
        }
    }

    func cachesDirectory() -> String {
        let paths:[String] = NSSearchPathForDirectoriesInDomains(SearchPathDirectory.cachesDirectory, SearchPathDomainMask.userDomainMask, true)
        return paths.first ?? ""
    }

    func tmpDirectory() -> String {
        return NSTemporaryDirectory()
    }

    func pathForFileInCachesDirectory(fileName:String) -> String {
        let fullPath:String = String(format: "%@/%@", cachesDirectory(), fileName)
        return fullPath
    }

    func documentDirectoryPath() -> String {
        let paths:[String] = NSSearchPathForDirectoriesInDomains(SearchPathDirectory.documentDirectory, SearchPathDomainMask.userDomainMask, true)
        return paths.first ?? ""
    }

    func iinkDirectory() -> String {
        let documentDirectory:NSString = documentDirectoryPath() as NSString
        return documentDirectory.appendingPathComponent("iinkFiles")
    }

    func documentInboxDirectory() -> String {
        let documentDirectory:NSString = documentDirectoryPath() as NSString
        return documentDirectory.appendingPathComponent("Inbox")
    }

    func libraryDirectory() -> String {
        let paths:[String] = NSSearchPathForDirectoriesInDomains(SearchPathDirectory.libraryDirectory, SearchPathDomainMask.userDomainMask, true)
        return paths.first ?? ""
    }

    func pathForFileInDocumentDirectory(fileName:String) -> String {
        let fullPath:String = String(format: "%@/%@", documentDirectoryPath(), fileName)
        return fullPath
    }

    func pathForFileInIinkDirectory(fileName:String) -> String {
        let fullPath:String = String(format: "%@/%@", iinkDirectory(), fileName)
        return fullPath
    }

    func pathForFileInLibraryDirectory(fileName:String) -> String {
        let fullPath:String = String(format: "%@/%@", libraryDirectory(), fileName)
        return fullPath
    }

    func pathForFileInTmpDirectory(fileName:String) -> String {
        let fullPath:String = String(format: "%@%@", tmpDirectory(), fileName)
        return fullPath
    }
}
