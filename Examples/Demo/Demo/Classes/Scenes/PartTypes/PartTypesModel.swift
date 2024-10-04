// Copyright @ MyScript. All rights reserved.

import Foundation

struct PartTypeModel: Equatable {
    var partType: String
    var configuration: String
    var displayName: String
    var selected: Bool = false

    init(partType: String, configuration: String, displayName: String, selected: Bool = false) {
        self.partType = partType
        self.selected = selected
        self.displayName = displayName
        self.configuration = configuration
    }
}

struct PartTypeCreationModel: Equatable {
    var partType: PartTypeModel
    var onNewPackage: Bool = false

    init(partType: PartTypeModel, onNewPackage: Bool) {
        self.partType = partType
        self.onNewPackage = onNewPackage
    }
}

struct PartTypesModel {
    var partTypes: [PartTypeModel] = [PartTypeModel]()
    var createBarButtonItem: UIBarButtonItem?
    var cancelBarButtonItem: UIBarButtonItem?

    init(partTypes: [PartTypeModel], createBarButtonItem: UIBarButtonItem?, cancelBarButtonItem: UIBarButtonItem? = nil ) {
        self.partTypes = partTypes
        self.createBarButtonItem = createBarButtonItem
        self.cancelBarButtonItem = cancelBarButtonItem
    }
}
