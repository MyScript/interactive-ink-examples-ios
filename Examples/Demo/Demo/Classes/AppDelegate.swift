// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // create iink folder in Documents. Future iink user files will be saved there.
        FileManager.default.createIinkDirectory()
        // create the main navigation controller to be used for our app
        let navController = UINavigationController()
        // send that into our coordinator so that it can display view controllers
        coordinator = MainCoordinator(navigationController: navController, engine: EngineProvider.sharedInstance.engine)
        // tell the coordinator to take over control
        coordinator?.start()
        // create a basic UIWindow and activate it
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}
