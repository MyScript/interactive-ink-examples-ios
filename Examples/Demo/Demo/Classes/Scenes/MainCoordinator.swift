// Copyright @ MyScript. All rights reserved.

import Foundation

private let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

/// The Storyboarded protocol is used to instanciate ViewControllers easily

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)
        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]
        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return mainStoryboard.instantiateViewController(withIdentifier: className) as! Self
    }
}

extension Storyboarded where Self: PartTypesTableViewController {
    static func instantiate(viewModel:PartTypesViewModel, coordinator:MainCoordinator) -> UINavigationController {
        let vc = instantiate()
        vc.viewModel = viewModel
        vc.coordinator = coordinator
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
}

extension Storyboarded where Self: FilesTableViewController {
    static func instantiate(coordinator:MainCoordinator) -> UINavigationController {
        let vc = instantiate()
        vc.coordinator = coordinator
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
}

extension Storyboarded where Self: ExportTableViewController {
    static func instantiate(viewModel:ExportViewModel, coordinator:MainCoordinator) -> UINavigationController {
        let vc = instantiate()
        vc.coordinator = coordinator
        vc.viewModel = viewModel
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
}

/// This class is the Coordinator of the Project. It's role is to deal with all the navigation (in this case instanciate and present/dismiss viewControllers, and eventually passing data to the next controller)

final class MainCoordinator {

    // MARK: Properties

    var navigationController: UINavigationController
    weak var mainViewController:MainViewController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        self.mainViewController = MainViewController.instantiate()
        self.mainViewController?.coordinator = self
        if let mainViewController = self.mainViewController {
            navigationController.pushViewController(mainViewController, animated: false)
        }
    }

    func dissmissModal() {
        self.navigationController.dismiss(animated: true, completion: nil)
    }

    // MARK :- Parts Management

    func createNewPart(cancelEnabled:Bool, onNewPackage:Bool) {
        let viewModel:PartTypesViewModel = PartTypesViewModel(engine: EngineProvider.sharedInstance.engine, cancelEnabled: cancelEnabled, onNewPackage: onNewPackage)
        let vc = PartTypesTableViewController.instantiate(viewModel: viewModel, coordinator: self)
        vc.isModalInPresentation = true
        self.navigationController.present(vc, animated: true, completion: nil)
    }

    func didSelectPartTypeToCreate(partType:SelectedPartTypeModel) {
        self.navigationController.dismiss(animated: true, completion: nil)
        self.mainViewController?.partTypeToCreate = partType
    }

    // MARK :- Files Management

    func openFilesList() {
        let vc = FilesTableViewController.instantiate(coordinator: self)
        vc.isModalInPresentation = true
        self.navigationController.present(vc, animated: true, completion: nil)
    }

    func didSelectFileToOpen(file:File) {
        self.navigationController.dismiss(animated: true, completion: nil)
        self.mainViewController?.fileToOpen = file
    }

    // MARK :- Export

    func displayExportOptions(editor:IINKEditor?) {
        let viewModel:ExportViewModel = ExportViewModel(editor: editor)
        let vc = ExportTableViewController.instantiate(viewModel: viewModel, coordinator: self)
        vc.isModalInPresentation = true
        self.navigationController.present(vc, animated: true, completion: nil)
    }

    func exportFinishedWithResult(result: ExportResultModel) {
        self.navigationController.dismiss(animated: true, completion: nil)
        self.mainViewController?.exportResult = result
    }
}
