// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// Protocol called by the FilesViewModel, in order to communicate with the Coordinator

protocol FilesTableViewControllerDisplayLogic : AnyObject {
    func cancel()
}

/// The FilesTableViewController role is to present the list of all the files created in the Demo modally. Once the user has chosen one, the modal is dissmissed and the value is given to the MainViewController (via the coordinator) in order to open the file.

class FilesTableViewController : UITableViewController, Storyboarded {

    // MARK: Properties

    weak var coordinator: MainCoordinator?
    var viewModel:FilesViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private let cellId = "FileCellReuseIdentifier"

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = FilesViewModel(delegate: self)
        self.bindViewModel()
        self.viewModel?.loadData()
    }

    // MARK: Data Binding

    private func bindViewModel() {
        self.viewModel?.$model.sink(receiveValue: { [weak self] model in
            if let model = model {
                self?.navigationItem.rightBarButtonItem = model.openBarButtonItem
                self?.navigationItem.leftBarButtonItem = model.cancelBarButtonItem
                self?.bindRightBarButtonItem()
                self?.tableView.reloadData()
            }
        }).store(in: &cancellables)
        self.viewModel?.$selectedFile.sink(receiveValue: { [weak self] file in
            if let file = file {
                self?.coordinator?.didSelectFileToOpen(file: file)
            }
        }).store(in: &cancellables)
    }

    private func bindRightBarButtonItem() {
        if let rightBarButtonItem = self.navigationItem.rightBarButtonItem {
            self.viewModel?.$openBarButtonItemEnabled.assign(to: \.isEnabled, on: rightBarButtonItem).store(in: &cancellables)
        }
    }

    // MARK: TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.model?.files.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fileModel:FileModel? = viewModel?.model?.files[indexPath.row]
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellId) ??
                                   UITableViewCell(style: .value1, reuseIdentifier: cellId)
        if let fileModel = fileModel {
            cell.textLabel?.text = fileModel.file?.fileName
            cell.detailTextLabel?.text = fileModel.details
            cell.accessoryType = fileModel.selected ? .checkmark : .none
            cell.isSelected = fileModel.selected
        }
        return cell
     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let oldSelectedIndexPath = viewModel?.selectedIndexPath {
            tableView.deselectRow(at: oldSelectedIndexPath, animated: true)
        }
        self.viewModel?.selectElement(indexPath: indexPath)
        tableView.reloadData()
    }
}

extension FilesTableViewController : FilesTableViewControllerDisplayLogic {

    func cancel() {
        self.coordinator?.dissmissModal()
    }
}
