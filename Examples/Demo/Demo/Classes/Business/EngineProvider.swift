// Copyright @ MyScript. All rights reserved.

import Foundation

/// The EngineProvider is used to manage the creation and the exposition of the Engine to the rest of the classes. It's important to use the same instance during all the application life cycle (hence the Singleton).

class EngineProvider {

    static var sharedInstance = EngineProvider()
    var engineErrorMessage: String = ""

    /**
     * IINK Engine, lazy loaded.
     *
     * @return the iink engine.
     */
     lazy var engine: IINKEngine? = {

        // Check that the MyScript certificate is present
        if myCertificate.length == 0 {
            self.engineErrorMessage = "Please replace the content of MyCertificate.c with the certificate you received from the developer portal"
            return nil
        }

        // Create the iink runtime environment
        let data = Data(bytes: myCertificate.bytes, count: myCertificate.length)
        guard let engine = IINKEngine(certificate: data) else {
            self.engineErrorMessage = "Invalid certificate"
            return nil
        }

        // Configure the iink runtime environment
        let configurationPath = Bundle.main.bundlePath.appending("/recognition-assets/conf")
        do {
            try engine.configuration.set(stringArray: [configurationPath],
                                         forKey: "configuration-manager.search-path") // Tells the engine where to load the recognition assets from.
        } catch {
            print("Should not happen, please check your resources assets : " + error.localizedDescription)
            return nil
        }

        // Set the temporary directory
        do {
            try engine.configuration.set(string: NSTemporaryDirectory(),
                                         forKey: "content-package.temp-folder")
        } catch {
            print("Failed to set temporary folder: " + error.localizedDescription)
            return nil
        }

        // Set dropShadow config
        try? engine.configuration.set(number: 0, forKey: "renderer.drop-shadow.x-offset")
        try? engine.configuration.set(number: 5, forKey: "renderer.drop-shadow.y-offset")
        try? engine.configuration.set(number: 0x00000066, forKey: "renderer.drop-shadow.color")
        try? engine.configuration.set(number: 5, forKey: "renderer.drop-shadow.radius")

        return engine
    }()
}
