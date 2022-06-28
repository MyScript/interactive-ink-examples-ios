// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// Protocol called by the MainViewModel, in order to communicate with the Coordinator

protocol MainViewControllerDisplayLogic: AnyObject {
    func displayExportOptions()
    func displayOpenDocumentOptions()
    func displayNewDocumentOptions(cancelEnabled: Bool)
    func displayImagePicker()
}

/// This is the Main ViewController of the project.
/// It Encapsulates the EditorViewController, permits editing actions (such as undo/redo), and handles pages management.

class MainViewController: UIViewController, Storyboarded {

    // MARK: Outlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var addPartBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var previousPartBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var nextPartBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var convertBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var zoomOutBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var zoomInBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var navToolbarContainer: UIView!

    // MARK: Properties

    weak var coordinator: MainCoordinator?
    var partTypeToCreate: SelectedPartTypeModel? {
        didSet {
            if let partTypeToCreate = self.partTypeToCreate {
                self.viewModel?.createNewPart(partType: partTypeToCreate, engineProvider: EngineProvider.sharedInstance)
            }
        }
    }
    var fileToOpen: File? {
        didSet {
            if let file = self.fileToOpen {
                self.viewModel?.openFile(file: file, engineProvider: EngineProvider.sharedInstance)
            }
        }
    }
    private(set) var viewModel: MainViewModel?
    private var longPressgestureRecognizer: UILongPressGestureRecognizer?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = MainViewModel(delegate: self,
                                       engineProvider: EngineProvider.sharedInstance,
                                       toolingWorker: ToolingWorker(),
                                       editorWorker: EditorWorker())
        self.bindViewModel()
        self.viewModel?.checkEngineProviderValidity()
        self.viewModel?.enableRawContentConversion()
        self.coordinator?.displayEditor(editorDelegate: self.viewModel, smartGuideDelegate: self.viewModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let fileFound = self.viewModel?.openLastModifiedFileIfAny() ?? false
        self.coordinator?.displayToolBar(editingEnabled: fileFound)
    }

    // MARK: Data Binding

    private func bindViewModel() {
        // Enable/Disable buttons and gestures
        self.viewModel?.$addPartItemEnabled.assign(to: \.isEnabled, on: self.addPartBarButtonItem).store(in: &cancellables)
        self.viewModel?.$editingEnabled.assign(to: \.isEnabled, on: self.convertBarButtonItem).store(in: &cancellables)
        self.viewModel?.$editingEnabled.assign(to: \.isEnabled, on: self.zoomInBarButtonItem).store(in: &cancellables)
        self.viewModel?.$editingEnabled.assign(to: \.isEnabled, on: self.zoomOutBarButtonItem).store(in: &cancellables)
        self.viewModel?.$editingEnabled.assign(to: \.isEnabled, on: self.moreBarButtonItem).store(in: &cancellables)
        self.viewModel?.$editingEnabled.sink { [weak self] enabled in
            self?.coordinator?.enableEditing(enable: enabled)
        }.store(in: &cancellables)
        self.viewModel?.$previousButtonEnabled.assign(to: \.isEnabled, on: self.previousPartBarButtonItem).store(in: &cancellables)
        self.viewModel?.$nextButtonEnabled.assign(to: \.isEnabled, on: self.nextPartBarButtonItem).store(in: &cancellables)
        self.viewModel?.$longPressGestureEnabled.removeDuplicates().sink { [weak self] enabled in
            self?.longPressgestureRecognizer?.isEnabled = enabled
        }.store(in: &cancellables)

        // View Model Title
        self.viewModel?.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)

        // AlertViewControllers
        self.viewModel?.$errorAlertModel.sink { [weak coordinator] errorAlertModel in
            guard let alertModel = errorAlertModel else {
                return
            }
            coordinator?.presentAlert(with: alertModel)
        }.store(in: &cancellables)
        self.viewModel?.$menuAlertModel.sink { [weak coordinator] menuAlertModel in
            guard let model = menuAlertModel else {
                return
            }
            coordinator?.presentAlertPopover(with: model)
        }.store(in: &cancellables)
        self.viewModel?.$inputAlertModel.sink { [weak self] inputAlertModel in
            guard let self = self,
                  let model = inputAlertModel else {
                return
            }
            self.coordinator?.presentInputAlert(with: model, delegate: self)
        }.store(in: &cancellables)
        self.viewModel?.$moreActionsAlertModel.sink { [weak coordinator] moreActionsAlertModel in
            guard let model = moreActionsAlertModel else {
                return
            }
            coordinator?.presentAlertPopover(with: model)
        }.store(in: &cancellables)
    }

    // MARK: - UI config

    func injectToolbar(toolBar:ToolbarViewController) {
        self.injectViewController(viewController: toolBar, in: self.navToolbarContainer)
    }

    func injectEditor(editor:EditorViewController) {
        self.injectViewController(viewController: editor, in: self.containerView)
        // Long Press Gesture
        self.longPressgestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizerAction))
        self.longPressgestureRecognizer?.isEnabled = true
        self.longPressgestureRecognizer?.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        if let longPressGesture = self.longPressgestureRecognizer {
            editor.view.addGestureRecognizer(longPressGesture)
        }
    }

    private func injectViewController(viewController:UIViewController, in container:UIView) {
        self.addChild(viewController)
        container.addSubview(viewController.view)
        viewController.view.frame = container.bounds
        viewController.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // resize editor view (after rotation for example)
        for view in self.containerView.subviews {
            view.frame = self.containerView.bounds
        }
    }

    // MARK: Actions

    @IBAction private func convert(_ sender: Any) {
        self.viewModel?.convert()
    }

    @IBAction private func zoomIn(_ sender: Any) {
        self.viewModel?.zoomIn()
    }

    @IBAction private func zoomOut(_ sender: Any) {
        self.viewModel?.zoomOut()
    }

    @IBAction private func moreButtonTapped(_ sender: Any) {
        self.viewModel?.moreActions(barButtonIdem: self.moreBarButtonItem)
    }

    @IBAction private func nextPart(_ sender: Any) {
        self.viewModel?.loadNextPart()
    }

    @IBAction private func previousPart(_ sender: Any) {
        self.viewModel?.loadPreviousPart()
    }

    @IBAction private func addPart(_ sender: Any) {
        self.coordinator?.createNewPart(cancelEnabled: true, onNewPackage: false)
    }

    // MARK: LongPress Gesture

    @objc private func longPressGestureRecognizerAction() {
        guard let longPressgestureRecognizer = self.longPressgestureRecognizer else { return }
        let position:CGPoint = longPressgestureRecognizer.location(in: longPressgestureRecognizer.view)
        if let sourceView = longPressgestureRecognizer.view {
            self.viewModel?.handleLongPressGesture(state: longPressgestureRecognizer.state, position: position, sourceView: sourceView)
        }
    }
}

extension MainViewController: MainViewControllerDisplayLogic {

    func displayOpenDocumentOptions() {
        self.coordinator?.openFilesList()
    }

    func displayNewDocumentOptions(cancelEnabled: Bool) {
        self.coordinator?.createNewPart(cancelEnabled: cancelEnabled, onNewPackage: true)
    }

    func displayExportOptions() {
        self.coordinator?.displayExportOptions(editor: viewModel?.editor)
    }

    func displayImagePicker() {
        self.coordinator?.presentImagePicker(delegate: self)
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.coordinator?.dissmissModal()
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        self.viewModel?.addImageBlock(with: image)
    }
}

extension MainViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.viewModel?.addTextBlockValue = textField.text ?? ""
    }
}

extension MainViewController: ToolbarProtocol {

    func undo() {
        self.viewModel?.undo()
    }

    func redo() {
        self.viewModel?.redo()
    }

    func clear() {
        self.viewModel?.clear()
    }

    func didSelectTool(tool: IINKPointerTool) {
        self.viewModel?.selectTool(tool: tool)
    }

    func didChangeActivePenMode(activated: Bool) {
        self.viewModel?.didChangeActivePenMode(activated: activated)
    }

    func didSelectStyle(style:ToolStyleModel) {
        self.viewModel?.didSelectStyle(style: style)
    }
}
