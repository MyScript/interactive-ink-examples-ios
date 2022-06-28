// Copyright @ MyScript. All rights reserved.

import Foundation

struct ActionModel {
    var actionText: String?
    var style: UIAlertAction.Style = .default
    var handler: ((UIAlertAction) -> ())?
}

struct AlertModel {
    var title: String?
    var message: String?
    var alertStyle: UIAlertController.Style = .alert
    var actionModels: [ActionModel]
    var sourceView: UIView?
    var sourceRect: CGRect?
}
