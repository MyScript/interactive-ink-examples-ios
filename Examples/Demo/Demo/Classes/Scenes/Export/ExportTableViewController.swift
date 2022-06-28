// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// Protocol called by the ExportViewModel, in order to communicate with the Coordinator

protocol ExportTableViewControllerDisplayLogic : AnyObject {
    func cancel()
    func exportFinishedWithResult(result: AlertModel)
}

/// The ExportTableViewController role is to present to possible export formats modally, depending on the selected Block type (Text, Image...). Once the user has chosen one, the modal is dissmissed and the Block is exported in the application data container.

class ExportTableViewController: UITableViewController, Storyboarded {

    // MARK: Properties

    weak var coordinator: MainCoordinator?
    var viewModel:ExportViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private let cellId = "ExportCellReuseIdentifier"

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.delegate = self
        self.bindViewModel()
        self.viewModel?.loadData()
    }

    // MARK: Data Binding

    private func bindViewModel() {
        self.viewModel?.$model.sink(receiveValue: { [weak self] model in
            if let model = model {
                self?.navigationItem.leftBarButtonItem = model.cancelBarButtonItem
                self?.tableView.reloadData()
            }
        }).store(in: &cancellables)
    }

    // MARK: TableView

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return self.viewModel?.model?.description
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.model?.mimeTypes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mimeTypeValue:IINKMimeTypeValue? = viewModel?.model?.mimeTypes[indexPath.row]
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let mimeTypeValue = mimeTypeValue {
            cell.textLabel?.text = IINKMimeTypeValue.iinkMimeTypeGetName(mimeTypeValue.value)
        }
        return cell
     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel?.export(indexOfMimeTypeSelected: indexPath.row)
    }

    private func configureTableView() {
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellId)
    }

}

extension ExportTableViewController : ExportTableViewControllerDisplayLogic {

    func cancel() {
        self.coordinator?.dissmissModal()
    }

    func exportFinishedWithResult(result: AlertModel) {
        self.coordinator?.dissmissModal()
        self.coordinator?.presentAlert(with: result)
    }
}
