// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// This class is the ViewModel of the PartTypesTableViewController. It handles all its business logic.

class PartTypesViewModel {

    // MARK: Published Properties

    @Published var model: PartTypesModel?
    @Published var createBarButtonItemEnabled: Bool = false
    @Published var selectedPartType: PartTypeCreationModel?

    // MARK: Properties

    var engine: IINKEngine?
    var selectedIndexPath: IndexPath?
    private var cancelBarButtonItemEnabled: Bool = true
    private var onNewPackage: Bool = false
    weak var delegate: PartTypesViewControllerDisplayLogic?

    // MARK: Init

    init(engine:IINKEngine?, cancelEnabled: Bool, onNewPackage: Bool) {
        self.engine = engine
        self.onNewPackage = onNewPackage
        self.cancelBarButtonItemEnabled = cancelEnabled
    }

    // MARK: Business Logic

    func loadData() {
        let createBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(create))
        createBarButtonItem.isEnabled = false
        var cancelBarButtonItem: UIBarButtonItem? = nil
        if cancelBarButtonItemEnabled {
            cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        }
        let partTypeModels: [PartTypeModel] = self.supportedPartTypesAndProfiles()
        self.model = PartTypesModel(partTypes: partTypeModels,
                                    createBarButtonItem: createBarButtonItem,
                                    cancelBarButtonItem: cancelBarButtonItem)
    }

    private func supportedPartTypesAndProfiles() -> [PartTypeModel] {
        var result = [PartTypeModel]()
        if let supportedPartTypes = engine?.supportedPartTypes {
            let configurationsPath = Bundle.main.bundlePath.appending("/configurations/")
            for partType in supportedPartTypes {
                // Append PartType with default config profile
                result.append(PartTypeModel(partType: partType,
                                            configuration: "",
                                            displayName: partType))
                // Then try to find custom config profiles for this PartType and append them
                // Configs for PartTypes are json files, and they are always located in "/configurations/{PartType}/{configName}.json"
                let partTypePath = configurationsPath.appending(partType)
                if FileManager.default.fileExists(atPath: partTypePath),
                   let configFiles = try? FileManager.default.contentsOfDirectory(atPath: partTypePath) {
                    for configFile in configFiles {
                        if configFile.hasSuffix(".json"),
                           let profileName = configFile.split(separator: ".").first {
                            result.append(PartTypeModel(partType: partType,
                                                        configuration: String(profileName),
                                                        displayName: "\(partType) (\(profileName))"))
                        }
                    }
                }
            }
        }
        return result
    }

    func selectElement(indexPath: IndexPath) {
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
           let partType = self.model?.partTypes[selectedIndexPath.row] {
            self.selectedPartType = PartTypeCreationModel(partType: partType, onNewPackage: self.onNewPackage)
        }
    }

    @objc private func cancel() {
        self.delegate?.cancel()
    }

}
