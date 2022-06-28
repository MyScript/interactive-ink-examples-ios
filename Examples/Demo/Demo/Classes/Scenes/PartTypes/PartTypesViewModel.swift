// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// This class is the ViewModel of the PartTypesTableViewController. It handles all its business logic.

class PartTypesViewModel {

    // MARK: Published Properties

    @Published var model:PartTypesModel?
    @Published var createBarButtonItemEnabled:Bool = false
    @Published var selectedPartType:SelectedPartTypeModel?

    // MARK: Properties

    var engine:IINKEngine?
    var selectedIndexPath:IndexPath?
    private var cancelBarButtonItemEnabled:Bool = true
    private var onNewPackage:Bool = false
    weak var delegate:PartTypesViewControllerDisplayLogic?

    // MARK: Init

    init(engine:IINKEngine?, cancelEnabled:Bool, onNewPackage:Bool) {
        self.engine = engine
        self.onNewPackage = onNewPackage
        self.cancelBarButtonItemEnabled = cancelEnabled
    }

    // MARK: Business Logic

    func loadData() {
        if let engine = engine {
            let createBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(create))
            createBarButtonItem.isEnabled = false
            var cancelBarButtonItem:UIBarButtonItem? = nil
            if cancelBarButtonItemEnabled {
                cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            }
            var partTypeModels:[PartTypeModel] = [PartTypeModel]()
            for partType in engine.supportedPartTypes {
                partTypeModels.append(PartTypeModel(partType: partType, selected: false))
            }
            self.model = PartTypesModel(partTypes: partTypeModels, createBarButtonItem: createBarButtonItem, cancelBarButtonItem: cancelBarButtonItem)
        }
    }

    func selectElement(indexPath:IndexPath) {
        if self.model?.partTypes.count ?? 0 > indexPath.row {
            if let selectedIndexPath = self.selectedIndexPath {
                // deselect old partType
                self.model?.partTypes[selectedIndexPath.row].selected = false
            }
            self.selectedIndexPath = indexPath
            self.createBarButtonItemEnabled = true
            // select new partType
            self.model?.partTypes[indexPath.row].selected = true
        }
    }

    @objc private func create() {
        if let selectedIndexPath = self.selectedIndexPath,
           let partType = self.model?.partTypes[selectedIndexPath.row].partType {
            self.selectedPartType = SelectedPartTypeModel(partType: partType, onNewPackage: self.onNewPackage)
        }
    }

    @objc private func cancel() {
        self.delegate?.cancel()
    }

}
