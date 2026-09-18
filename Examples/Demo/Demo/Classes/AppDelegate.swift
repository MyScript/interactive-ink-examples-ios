// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // create iink folder in Documents. Future iink user files will be saved there.
        FileManager.default.createIinkDirectory()
        return true
    }
}
