// Copyright @ MyScript. All rights reserved.

import Foundation

class AlertBuilder {

    static func buildAlertController(for model: AlertModel) -> UIAlertController {
        let controller = UIAlertController(title: model.title,
                                           message: model.message,
                                           preferredStyle: model.alertStyle)
        model.actionModels.forEach({controller.addAction(UIAlertAction(title: $0.actionText,
                                                                       style: $0.style,
                                                                       handler: $0.handler))})
        return controller
    }

    static func buildInputAlertController(for model: AlertModel, delegate: UITextFieldDelegate) -> UIAlertController {
        let controller = UIAlertController(title: model.title,
                                           message: model.message,
                                           preferredStyle: model.alertStyle)
        controller.addTextField(configurationHandler: { textfield in
            textfield.delegate = delegate
        })
        model.actionModels.forEach({controller.addAction(UIAlertAction(title: $0.actionText,
                                                                       style: $0.style,
                                                                       handler: $0.handler))})
        return controller
    }
}
