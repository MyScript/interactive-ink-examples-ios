// Copyright @ MyScript. All rights reserved.

import Foundation

struct File: Equatable {

    var fileName: String
    var modificationDate: Date
    var fileSize: Float

    init(fileName: String, modificationDate: Date, fileSize: Float ) {
        self.fileName = fileName
        self.modificationDate = modificationDate
        self.fileSize = fileSize
    }
}

struct FileModel {

    var file: File?
    var details: String
    var selected: Bool = false

    init(file: File, selected: Bool) {
        self.file = file
        self.selected = selected
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        self.details = String(format: "%@ | %.3f Mb", dateFormatter.string(from: file.modificationDate), file.fileSize / 1000000)
    }
}

struct FilesModel {

    var files: [FileModel] = [FileModel]()
    var openBarButtonItem: UIBarButtonItem?
    var cancelBarButtonItem: UIBarButtonItem?

    init(files: [FileModel], openBarButtonItem: UIBarButtonItem?, cancelBarButtonItem: UIBarButtonItem? = nil ) {
        self.files = files
        self.openBarButtonItem = openBarButtonItem
        self.cancelBarButtonItem = cancelBarButtonItem
    }
}
