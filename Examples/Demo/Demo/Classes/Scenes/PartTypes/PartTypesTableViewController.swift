// Copyright @ MyScript. All rights reserved./

import Foundation
import Combine

/// Protocol called by the PartTypesTableViewModel, in order to communicate with the Coordinator

protocol PartTypesViewControllerDisplayLogic : AnyObject {
    func cancel()
}

/// The PartTypesTableViewController role is to present a list of Part Types modally. Once the user has chosen one, the modal is dissmissed and the value is given to the MainViewController (via the coordinator) in order to create a new page of the selected type (Ex:Text Document)

class PartTypesTableViewController : UITableViewController, Storyboarded {

    // MARK: Properties

    weak var coordinator: MainCoordinator?
    var viewModel:PartTypesViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private let cellId = "PartTypeCellReuseIdentifier"

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.delegate = self
        self.bindViewModel()
        self.configureTableView()
        self.viewModel?.loadData()
    }

    // MARK: Data Binding

    private func bindViewModel() {
        self.viewModel?.$model.sink(receiveValue: { [weak self] model in
            if let model = model {
                self?.navigationItem.rightBarButtonItem = model.createBarButtonItem
                self?.navigationItem.leftBarButtonItem = model.cancelBarButtonItem
                self?.bindRightBarButtonItem()
                self?.tableView.reloadData()
            }
        }).store(in: &cancellables)
        self.viewModel?.$selectedPartType.sink(receiveValue: { [weak self] partType in
            if let partType = partType {
                self?.coordinator?.didSelectPartTypeToCreate(partType: partType)
            }
        }).store(in: &cancellables)
    }

    private func bindRightBarButtonItem() {
        if let rightBarButtonItem = self.navigationItem.rightBarButtonItem {
            self.viewModel?.$createBarButtonItemEnabled.assign(to: \.isEnabled, on: rightBarButtonItem).store(in: &cancellables)
        }
    }

    // MARK: TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.model?.partTypes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let partType:PartTypeModel? = viewModel?.model?.partTypes[indexPath.row]
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let partType = partType {
            cell.textLabel?.text = partType.partType
            cell.accessoryType = partType.selected ? .checkmark : .none
            cell.isSelected = partType.selected
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

    private func configureTableView() {
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellId)
    }
}

extension PartTypesTableViewController : PartTypesViewControllerDisplayLogic {

    func cancel() {
        self.coordinator?.dissmissModal()
    }
}
