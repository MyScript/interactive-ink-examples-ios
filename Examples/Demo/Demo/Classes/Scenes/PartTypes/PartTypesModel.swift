// Copyright @ MyScript. All rights reserved.

import Foundation

struct PartTypeModel {
    var partType:String = ""
    var selected:Bool = false

    init(partType:String, selected:Bool) {
        self.partType = partType
        self.selected = selected
    }
}

struct SelectedPartTypeModel {
    var partType:String = ""
    var onNewPackage:Bool = false

    init(partType:String, onNewPackage:Bool) {
        self.partType = partType
        self.onNewPackage = onNewPackage
    }
}

struct PartTypesModel {
    var partTypes:[PartTypeModel] = [PartTypeModel]()
    var createBarButtonItem: UIBarButtonItem?
    var cancelBarButtonItem: UIBarButtonItem?

    init(partTypes:[PartTypeModel], createBarButtonItem: UIBarButtonItem?, cancelBarButtonItem: UIBarButtonItem? = nil ) {
        self.partTypes = partTypes
        self.createBarButtonItem = createBarButtonItem
        self.cancelBarButtonItem = cancelBarButtonItem
    }
}
