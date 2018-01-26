// Copyright MyScript. All right reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var engineErrorMessage: String?

    /**
     * IINK Engine, lazy loaded.
     *
     * @return the iink engine.
     */
    lazy var engine: IINKEngine? = {
        // Check that the MyScript certificate is present
        if myCertificate.length == 0
        {
            self.engineErrorMessage = "Please replace the content of MyCertificate.c with the certificate you received from the developer portal"
            return nil
        }

        // Create the iink runtime environment
        let data = Data(bytes: myCertificate.bytes, count: myCertificate.length)
        guard let engine = IINKEngine(certificate: data) else
        {
            self.engineErrorMessage = "Invalid certificate"
            return nil
        }

        // Configure the iink runtime environment
        let configurationPath = Bundle.main.bundlePath.appending("/recognition-assets/conf")
        do {
            try engine.configuration.setStringArray("configuration-manager.search-path", value: [configurationPath]) // Tells the engine where to load the recognition assets from.
        } catch {
            print("Should not happen, please check your resources assets : " + error.localizedDescription)
            return nil
        }
        
        // Set the temporary directory
        do {
            try engine.configuration.setString("content-package.temp-folder", value: NSTemporaryDirectory())
        } catch {
            print("Failed to set temporary folder: " + error.localizedDescription)
            return nil
        }

        return engine
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
}
