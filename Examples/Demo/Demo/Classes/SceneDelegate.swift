// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// Owns the UI life cycle of a single window scene: it builds the window and hands control to the coordinator.

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        // create the main navigation controller to be used for our app
        let navController = UINavigationController()
        // send that into our coordinator so that it can display view controllers
        coordinator = MainCoordinator(navigationController: navController, engine: EngineProvider.sharedInstance.engine)
        // tell the coordinator to take over control
        coordinator?.start()
        // create the window bound to this scene and activate it
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }
}
