// Copyright @ MyScript. All rights reserved.

import Foundation

/// The Storyboarded protocol is used to instanciate ViewControllers easily

protocol Storyboarded {
    static func instantiate(from storyboardName: StoryboardNames) -> Self?
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(from storyboardName: StoryboardNames) -> Self? {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: .main)
        let className = String(describing: self)
        if let viewController = storyboard.instantiateViewController(withIdentifier: className) as? Self {
            return viewController
        }
        return nil
    }
}

extension Storyboarded where Self: PartTypesTableViewController {
    static func instantiate(viewModel: PartTypesViewModel, coordinator: MainCoordinator) -> UINavigationController? {
        guard let vc = instantiate(from: .main) else {
            return nil
        }
        vc.viewModel = viewModel
        vc.coordinator = coordinator
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
}

extension Storyboarded where Self: FilesTableViewController {
    static func instantiate(coordinator: MainCoordinator) -> UINavigationController? {
        guard let vc = instantiate(from: .main) else {
            return nil
        }
        vc.coordinator = coordinator
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
}

extension Storyboarded where Self: ExportTableViewController {
    static func instantiate(viewModel: ExportViewModel, coordinator: MainCoordinator) -> UINavigationController? {
        guard let vc = instantiate(from: .main) else {
            return nil
        }
        vc.coordinator = coordinator
        vc.viewModel = viewModel
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
}
