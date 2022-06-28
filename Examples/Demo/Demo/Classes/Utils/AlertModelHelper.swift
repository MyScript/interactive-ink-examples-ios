// Copyright @ MyScript. All rights reserved.

import Foundation

struct AlertModelHelper {

    static func createAlertModel(with error: ToolingWorker.ToolingError) -> AlertModel {
        switch error {
        case .setToolFailed, .noPartType:
            print("An error occurred with the tool selection: \(error)")
            return self.createDefaultErrorAlert(message: "An error occurred during the tool selection",
                                                exitAppWhenClosed: false)
        case .lassoNotSupported:
            return self.createDefaultErrorAlert(message: "The lasso is not supported for this page type",
                                                exitAppWhenClosed: false)
        case .setToolStyleFailed:
            print("An error occurred while setting the tool style: \(error)")
            return self.createDefaultErrorAlert(message: "An error occurred while setting the tool style",
                                                exitAppWhenClosed: false)
        }
    }

    static func createAlertModel(with error: EditorWorker.EditorError) -> AlertModel {
        switch error {
        case .partCreationFailed:
            return self.createDefaultErrorAlert(message: "An error occured during the page creation")
        case .convertFailed:
            return self.createDefaultErrorAlert(message: "An error occured during the convertion",
                                                exitAppWhenClosed: false)
        case .addImageFailed:
            return self.createDefaultErrorAlert(message: "An error occured while adding the image",
                                                exitAppWhenClosed: false)
        }
    }

    static func createDefaultErrorAlert(message: String, exitAppWhenClosed: Bool = true) -> AlertModel {
        return self.createAlert(title: "Error", message: message, exitAppWhenClosed: exitAppWhenClosed)
    }

    static func createAlert(title: String, message: String, exitAppWhenClosed: Bool = true) -> AlertModel {
        let action = ActionModel(actionText: "OK") { action in
            if exitAppWhenClosed {
                exit(1)
            }
        }
        return AlertModel(title: title, message: message, actionModels: [action])
    }
}
