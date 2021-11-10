// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

/// Protocol called by the MainViewModel, in order to communicate with the Coordinator

protocol MainViewControllerDisplayLogic:AnyObject {
    func displayExportOptions()
    func displayOpenDocumentOptions()
    func displayNewDocumentOptions()
}

/// This is the Main ViewController of the project.
/// It Encapsulates the EditorViewController, permits editing actions (such as undo/redo), and handles pages management.

class MainViewController : UIViewController, Storyboarded {

    // MARK: Outlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addPartBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var previousPartBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var nextPartBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var convertBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var moreBarButtonItem: UIBarButtonItem!

    // MARK: Properties

    weak var coordinator: MainCoordinator?
    var partTypeToCreate:SelectedPartTypeModel? {
        didSet {
            if let partTypeToCreate = self.partTypeToCreate {
                self.viewModel?.createNewPart(partType: partTypeToCreate, engineProvider: EngineProvider.sharedInstance)
            }
        }
    }
    var fileToOpen:File? {
        didSet {
            if let file = self.fileToOpen {
                self.viewModel?.openFile(file: file, engineProvider: EngineProvider.sharedInstance)
            }
        }
    }
    var exportResult:ExportResultModel? {
        didSet {
            if let exportResult = self.exportResult {
                self.viewModel?.handleExportResult(result: exportResult)
            }
        }
    }
    private var viewModel:MainViewModel?
    private var longPressgestureRecognizer:UILongPressGestureRecognizer?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = MainViewModel(delegate: self)
        self.bindViewModel()
        self.viewModel?.setupEditorController(engineProvider: EngineProvider.sharedInstance)
        // display partType selection in modal
        self.coordinator?.createNewPart(cancelEnabled: false, onNewPackage: true)
    }

    // MARK: Data Binding

    private func bindViewModel() {
        // Enable/Disable buttons
        self.viewModel?.$addPartItemEnabled.assign(to: \.isEnabled, on: self.addPartBarButtonItem).store(in: &cancellables)
        self.viewModel?.$editionButtonsEnabled.assign(to: \.isEnabled, on: self.undoButton).store(in: &cancellables)
        self.viewModel?.$editionButtonsEnabled.assign(to: \.isEnabled, on: self.redoButton).store(in: &cancellables)
        self.viewModel?.$editionButtonsEnabled.assign(to: \.isEnabled, on: self.clearButton).store(in: &cancellables)
        self.viewModel?.$editionButtonsEnabled.assign(to: \.isEnabled, on: self.convertBarButtonItem).store(in: &cancellables)
        self.viewModel?.$editionButtonsEnabled.assign(to: \.isEnabled, on: self.moreBarButtonItem).store(in: &cancellables)
        self.viewModel?.$previousButtonEnabled.assign(to: \.isEnabled, on: self.previousPartBarButtonItem).store(in: &cancellables)
        self.viewModel?.$nextButtonEnabled.assign(to: \.isEnabled, on: self.nextPartBarButtonItem).store(in: &cancellables)
        // View Model (title, editorVC)
        self.viewModel?.$title.sink { title in self.title = title }.store(in: &cancellables)
        self.viewModel?.$editorViewController.sink { [weak self] editorViewController in
            if let editorViewController = editorViewController {
                self?.injectEditor(editor: editorViewController)
            }
        }.store(in: &cancellables)
        // AlertViewControllers
        self.viewModel?.$errorAlertController.sink { [weak self] alert in
            guard let unwrappedAlert = alert else { return }
            self?.present(unwrappedAlert, animated: true, completion: nil)
        }.store(in: &cancellables)
        self.viewModel?.$menuAlertController.sink { [weak self] alert in
            guard let unwrappedAlert = alert else { return }
            self?.present(unwrappedAlert, animated: true, completion: nil)
        }.store(in: &cancellables)
        self.viewModel?.$inputAlertController.sink { [weak self] alert in
            guard let unwrappedAlert = alert else { return }
            self?.present(unwrappedAlert, animated: true, completion: nil)
        }.store(in: &cancellables)
        self.viewModel?.$moreActionsAlertController.sink { [weak self] alert in
            guard let unwrappedAlert = alert else { return }
            self?.present(unwrappedAlert, animated: true, completion: nil)
        }.store(in: &cancellables)
        // InpuMode Gesture Management
        self.viewModel?.$inputMode.sink { [weak self] newInputMode in
            switch newInputMode {
            case .forcePen:
                self?.longPressgestureRecognizer?.isEnabled = false
            case .forceTouch:
                self?.longPressgestureRecognizer?.isEnabled = true
                self?.longPressgestureRecognizer?.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.stylus.rawValue), NSNumber(value: UITouch.TouchType.direct.rawValue)]
            case .auto:
                self?.longPressgestureRecognizer?.isEnabled = true
                self?.longPressgestureRecognizer?.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
            }
        }.store(in: &cancellables)
    }

    // MARK: - EditorViewController UI config

    private func injectEditor(editor:EditorViewController) {
        self.addChild(editor)
        self.containerView.addSubview(editor.view)
        editor.view.frame = self.view.bounds
        editor.didMove(toParent: self)
        // Long Press Gesture
        self.longPressgestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizerAction))
        if let longPressGesture = self.longPressgestureRecognizer {
            editor.view.addGestureRecognizer(longPressGesture)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewModel?.setEditorViewSize(bounds: self.view.bounds)
    }

    // MARK: Actions

    @IBAction func undo(_ sender: Any) {
        self.viewModel?.undo()
    }

    @IBAction func redo(_ sender: Any) {
        self.viewModel?.redo()
    }

    @IBAction func clear(_ sender: Any) {
        self.viewModel?.clear()
    }

    @IBAction func convert(_ sender: Any) {
        self.viewModel?.convert()
    }

    @IBAction func moreButtonTapped(_ sender: Any) {
        self.viewModel?.moreActions(barButtonIdem: self.moreBarButtonItem)
    }

    @IBAction func nextPart(_ sender: Any) {
        self.viewModel?.loadNextPart()
    }

    @IBAction func previousPart(_ sender: Any) {
        self.viewModel?.loadPreviousPart()
    }

    @IBAction func addPart(_ sender: Any) {
        self.coordinator?.createNewPart(cancelEnabled: true, onNewPackage: false)
    }

    @IBAction func switchValueChanged(_ sender: UISegmentedControl) {
        self.viewModel?.updateInputMode(newInputModeIndex: sender.selectedSegmentIndex)
    }

    // MARK: LongPress Gesture

    @objc func longPressGestureRecognizerAction() {
        guard let longPressgestureRecognizer = self.longPressgestureRecognizer else { return }
        let position:CGPoint = longPressgestureRecognizer.location(in: longPressgestureRecognizer.view)
        if let sourceView = longPressgestureRecognizer.view {
            self.viewModel?.handleLongPressGesture(state: longPressgestureRecognizer.state, position: position, sourceView: sourceView)
        }
    }
}

extension MainViewController : MainViewControllerDisplayLogic {

    func displayOpenDocumentOptions() {
        self.coordinator?.openFilesList()
    }

    func displayNewDocumentOptions() {
        self.coordinator?.createNewPart(cancelEnabled: true, onNewPackage: true)
    }

    func displayExportOptions() {
        self.coordinator?.displayExportOptions(editor: viewModel?.editor)
    }
}
