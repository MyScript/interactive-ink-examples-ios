// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// This class is the ViewModel of the FilesTableViewController. It handles all its business logic.

class FilesViewModel {

    // MARK: Published Properties

    @Published var model:FilesModel?
    @Published var openBarButtonItemEnabled:Bool = false
    @Published var selectedFile:File?

    // MARK: Properties

    var selectedIndexPath:IndexPath?
    private weak var delegate:FilesTableViewControllerDisplayLogic?

    // MARK: Init

    init(delegate:FilesTableViewControllerDisplayLogic?) {
        self.delegate = delegate
    }

    // MARK: Business Logic

    func loadData() {
        let openBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(open))
        openBarButtonItem.isEnabled = false
        var cancelBarButtonItem:UIBarButtonItem? = nil
        cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        var fileModels:[FileModel] = [FileModel]()
        for file in FilesProvider.iinkFilesFromIInkDirectory() {
            fileModels.append(FileModel(file: file, selected: false))
        }
        self.model = FilesModel(files: fileModels, openBarButtonItem: openBarButtonItem, cancelBarButtonItem: cancelBarButtonItem)
    }

    func selectElement(indexPath:IndexPath) {
        if self.model?.files.count ?? 0 > indexPath.row {
            if let selectedIndexPath = self.selectedIndexPath {
                // deselect old File
                self.model?.files[selectedIndexPath.row].selected = false
            }
            self.selectedIndexPath = indexPath
            self.openBarButtonItemEnabled = true
            // select new File
            self.model?.files[indexPath.row].selected = true
        }
    }

    @objc private func open() {
        if let selectedIndexPath = self.selectedIndexPath,
           let file = self.model?.files[selectedIndexPath.row].file {
            self.selectedFile = file
        }
    }

    @objc private func cancel() {
        self.delegate?.cancel()
    }

}
