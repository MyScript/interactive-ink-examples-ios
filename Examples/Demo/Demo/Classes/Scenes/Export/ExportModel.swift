// Copyright @ MyScript. All rights reserved.

import Foundation

struct ExportModel {

    var title:String
    var description:String
    var mimeTypes:[IINKMimeTypeValue]
    var cancelBarButtonItem:UIBarButtonItem

    init(title:String, description:String, mimeTypes:[IINKMimeTypeValue], cancelBarButtonItem:UIBarButtonItem) {
        self.title = title
        self.description = description
        self.mimeTypes = mimeTypes
        self.cancelBarButtonItem = cancelBarButtonItem
    }
}
