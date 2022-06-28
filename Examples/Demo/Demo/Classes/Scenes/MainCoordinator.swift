// Copyright @ MyScript. All rights reserved.

import Foundation

/// This class is the Coordinator of the Project. It's role is to deal with all the navigation (in this case instanciate and present/dismiss viewControllers, and eventually passing data to the next controller)

final class MainCoordinator {

    // MARK: - Properties

    var navigationController: UINavigationController
    weak var mainViewController: MainViewController?
    weak var editorViewController: EditorViewController?
    weak var toolBarViewController: ToolbarViewController?
    private var engine: IINKEngine?

    init(navigationController: UINavigationController, engine: IINKEngine?) {
        self.navigationController = navigationController
        self.engine = engine
    }

    func start() {
        self.mainViewController = MainViewController.instantiate(from: .main)
        self.mainViewController?.coordinator = self
        if let mainViewController = self.mainViewController {
            navigationController.pushViewController(mainViewController, animated: false)
        }
    }

    func dissmissModal() {
        self.enableEditing(enable: true)
        self.navigationController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Editor

    func displayEditor(editorDelegate:EditorDelegate?, smartGuideDelegate:SmartGuideViewControllerDelegate?) {
        guard let mainViewController = self.mainViewController else {
            return
        }
        let editorViewModel:EditorViewModel = EditorViewModel(engine: self.engine,
                                                              inputMode: .auto,
                                                              editorDelegate: editorDelegate,
                                                              smartGuideDelegate: smartGuideDelegate)
        let editorViewController = EditorViewController(viewModel: editorViewModel)
        mainViewController.injectEditor(editor: editorViewController)
        self.editorViewController = editorViewController
    }

    func enablePanGesture(enable: Bool) {
        guard let editorVC = self.editorViewController else {
            return
        }
        editorVC.activateGestureRecognizer(enabled: enable)
    }

    // MARK: - Parts Management

    func createNewPart(cancelEnabled:Bool, onNewPackage:Bool) {
        let viewModel:PartTypesViewModel = PartTypesViewModel(engine: EngineProvider.sharedInstance.engine,
                                                              cancelEnabled: cancelEnabled,
                                                              onNewPackage: onNewPackage)
        guard let vc = PartTypesTableViewController.instantiate(viewModel: viewModel,
                                                                coordinator: self) else {
            return
        }
        vc.isModalInPresentation = true
        self.enableEditing(enable: false)
        self.navigationController.present(vc, animated: true, completion: nil)
    }

    func didSelectPartTypeToCreate(partType:SelectedPartTypeModel) {
        self.navigationController.dismiss(animated: true, completion: nil)
        self.mainViewController?.partTypeToCreate = partType
    }

    // MARK: - Files Management

    func openFilesList() {
        guard let vc = FilesTableViewController.instantiate(coordinator: self) else {
            return
        }
        vc.isModalInPresentation = true
        self.enableEditing(enable: false)
        self.navigationController.present(vc, animated: true, completion: nil)
    }

    func didSelectFileToOpen(file:File) {
        self.navigationController.dismiss(animated: true, completion: nil)
        self.mainViewController?.fileToOpen = file
    }

    // MARK: - Export

    func displayExportOptions(editor:IINKEditor?) {
        let viewModel:ExportViewModel = ExportViewModel(editor: editor)
        guard let vc = ExportTableViewController.instantiate(viewModel: viewModel,
                                                             coordinator: self) else {
            return
        }
        vc.isModalInPresentation = true
        self.navigationController.present(vc, animated: true, completion: nil)
    }

    // MARK: - Toolbar

    func displayToolBar(editingEnabled: Bool) {
        guard let mainViewController = self.mainViewController,
              let toolBar = ToolbarViewController.instantiate(delegate: mainViewController,
                                                              coordinator: self,
                                                              editingEnabledAtLaunch: editingEnabled) else {
            return
        }
        self.toolBarViewController = toolBar
        mainViewController.injectToolbar(toolBar: toolBar)
    }

    func displayToolStyle(tool:IINKPointerTool,
                          toolStyle:ToolStyleModel,
                          sourceView:UIView, delegate:ToolStyleProtocol) {
        guard let toolBarVC = self.toolBarViewController,
              let toolStyleVC = ToolStyleViewController.instantiate(tool: tool,
                                                                    toolStyle: toolStyle,
                                                                    delegate: delegate) else {
            return
        }
        toolStyleVC.preferredContentSize = CGSize(width: 320, height: 220)
        toolStyleVC.modalPresentationStyle = .popover
        toolStyleVC.popoverPresentationController?.sourceView = sourceView
        toolStyleVC.popoverPresentationController?.sourceRect = sourceView.bounds
        toolBarVC.present(toolStyleVC, animated: true, completion: nil)
    }

    func enableEditing(enable: Bool) {
        self.toolBarViewController?.enableEditing(enable: enable)
    }

    // MARK: - Image Picker

    func presentImagePicker(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = delegate
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = false
        self.mainViewController?.present(imagePickerController, animated: true, completion: nil)
    }

    // MARK: - Alerting

    func presentAlert(with model: AlertModel) {
        let alertVC = AlertBuilder.buildAlertController(for: model)
        self.mainViewController?.present(alertVC, animated: true, completion: {
            self.toolBarViewController?.selectPenTool(self)
        })
    }

    func presentAlertPopover(with model: AlertModel) {
        let alertVC = AlertBuilder.buildAlertController(for: model)
        let popover = alertVC.popoverPresentationController
        if let sourceRect = model.sourceRect {
            if let sourceView = model.sourceView {
               popover?.sourceView = sourceView
            } else {
                popover?.sourceView = self.mainViewController?.view
            }
            popover?.sourceRect = sourceRect
        } else {
            popover?.permittedArrowDirections = .up
            popover?.barButtonItem = self.mainViewController?.moreBarButtonItem
        }
        self.mainViewController?.present(alertVC, animated: true, completion: nil)
    }

    func presentInputAlert(with model: AlertModel, delegate: UITextFieldDelegate) {
        let alertVC = AlertBuilder.buildInputAlertController(for: model, delegate: delegate)
        self.mainViewController?.present(alertVC, animated: true, completion: nil)
    }
}
