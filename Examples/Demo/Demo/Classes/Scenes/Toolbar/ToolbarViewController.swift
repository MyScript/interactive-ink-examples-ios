// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

protocol ToolbarProtocol: AnyObject {
    func didSelectTool(tool: IINKPointerTool)
    func didChangeActivePenMode(activated: Bool)
    func didSelectStyle(style:ToolStyleModel)
    func undo()
    func redo()
    func clear()
}

class ToolbarViewController: UIViewController, Storyboarded {

    // MARK: Outlets

    @IBOutlet private weak var penButton: UIButton!
    @IBOutlet private weak var handButton: UIButton!
    @IBOutlet private weak var eraserButton: UIButton!
    @IBOutlet private weak var lassoButton: UIButton!
    @IBOutlet private weak var highlighterButton: UIButton!
    @IBOutlet private weak var undoButton: UIButton!
    @IBOutlet private weak var redoButton: UIButton!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var activePenLabel: UILabel!
    @IBOutlet private weak var activePenModeSwitch: UISwitch!
    @IBOutlet private weak var handButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var changeStyleButton: UIButton!

    // MARK: Properties

    private weak var delegate:ToolbarProtocol?
    private weak var coordinator: MainCoordinator?
    private var viewModel: ToolbarViewModel?
    private var editingEnabledAtLaunch: Bool = false
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Life Cycle

    static func instantiate(delegate: ToolbarProtocol,
                            coordinator: MainCoordinator,
                            editingEnabledAtLaunch: Bool) -> Self? {
        let toolbarVC = instantiate(from: .toolbar)
        toolbarVC?.delegate = delegate
        toolbarVC?.coordinator = coordinator
        toolbarVC?.editingEnabledAtLaunch = editingEnabledAtLaunch
        return toolbarVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ToolbarViewModel()
        self.bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.viewModel?.setup()
        self.enableEditing(enable: self.editingEnabledAtLaunch)
    }

    // MARK: Public

    func enableEditing(enable: Bool) {
        self.viewModel?.enableEditing(enable: enable)
    }

    // MARK: Data Binding

    private func bindViewModel() {
        // Active Tool
        self.viewModel?.$selectedTool.removeDuplicates().sink { [weak self] tool in
            if let tool = tool {
                self?.delegate?.didSelectTool(tool: tool)
            }
        }.store(in: &cancellables)

        // Tool Models
        self.viewModel?.$penToolModel.removeDuplicates().sink { [weak penButton] model in
            if let model = model {
                penButton?.setTitle(model.title, for: .normal)
                penButton?.tintColor = model.tintColor
                penButton?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$eraserToolModel.removeDuplicates().sink { [weak eraserButton] model in
            if let model = model {
                eraserButton?.setTitle(model.title, for: .normal)
                eraserButton?.tintColor = model.tintColor
                eraserButton?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$handToolModel.removeDuplicates().sink { [weak handButton, handButtonWidthConstraint] model in
            if let model = model {
                handButton?.setTitle(model.title, for: .normal)
                handButton?.tintColor = model.tintColor
                handButton?.isEnabled = model.enabled
                handButtonWidthConstraint?.constant = model.width
            }
        }.store(in: &cancellables)
        self.viewModel?.$lassoToolModel.removeDuplicates().sink { [weak lassoButton] model in
            if let model = model {
                lassoButton?.setTitle(model.title, for: .normal)
                lassoButton?.tintColor = model.tintColor
                lassoButton?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$highlighterToolModel.removeDuplicates().sink { [weak highlighterButton] model in
            if let model = model {
                highlighterButton?.setTitle(model.title, for: .normal)
                highlighterButton?.tintColor = model.tintColor
                highlighterButton?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$undoButtonModel.removeDuplicates().sink { [weak undoButton] model in
            if let model = model {
                undoButton?.setTitle(model.title, for: .normal)
                undoButton?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$redoButtonModel.removeDuplicates().sink { [weak redoButton] model in
            if let model = model {
                redoButton?.setTitle(model.title, for: .normal)
                redoButton?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$clearButtonModel.removeDuplicates().sink { [weak clearButton] model in
            if let model = model {
                clearButton?.setTitle(model.title, for: .normal)
                clearButton?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$styleButtonEnabled.removeDuplicates().sink { [weak changeStyleButton] enabled in
            changeStyleButton?.isEnabled = enabled
        }.store(in: &cancellables)

        // Active Pen Mode
        self.viewModel?.$activePenModel.removeDuplicates().sink { [weak activePenLabel, activePenModeSwitch] model in
            if let model = model {
                activePenLabel?.text = model.labelText
                activePenLabel?.textColor = model.labelColor
                activePenLabel?.isEnabled = model.enabled
                activePenModeSwitch?.onTintColor = model.switchColor
                activePenModeSwitch?.isEnabled = model.enabled
            }
        }.store(in: &cancellables)
        self.viewModel?.$enablePanGesture.removeDuplicates().sink { [weak self] enable in
            self?.coordinator?.enablePanGesture(enable: enable)
        }.store(in: &cancellables)

        // Tool Style Models
        self.viewModel?.$penStyleModel.removeDuplicates().sink { [weak self] model in
            if let model = model {
                self?.delegate?.didSelectStyle(style:model)
            }
        }.store(in: &cancellables)
        self.viewModel?.$highlighterStyleModel.removeDuplicates().sink { [weak self] model in
            if let model = model {
                self?.delegate?.didSelectStyle(style:model)
            }
        }.store(in: &cancellables)
    }

    // MARK: Actions

    @IBAction func selectPenTool(_ sender: Any) {
        self.viewModel?.selectPenTool()
    }

    @IBAction private func selectHandTool(_ sender: Any) {
        self.viewModel?.selectHandTool()
    }

    @IBAction private func selectEraserTool(_ sender: Any) {
        self.viewModel?.selectEraserTool()
    }

    @IBAction private func selectLassoTool(_ sender: Any) {
        self.viewModel?.selectLassoTool()
    }

    @IBAction private func selectHighlighterTool(_ sender: Any) {
        self.viewModel?.selectHighlighterTool()
    }

    @IBAction private func changeStyle(_ sender: Any) {
        guard let viewModel = self.viewModel,
              let activeTool = viewModel.selectedTool,
              let toolStyle = viewModel.getStyleForActiveTool() else {
            return
        }
        self.coordinator?.displayToolStyle(tool: activeTool,
                                           toolStyle: toolStyle,
                                           sourceView: self.changeStyleButton,
                                           delegate:viewModel)
    }

    @IBAction private func activePenModeValueChanged(_ sender: Any) {
        self.viewModel?.didChangeActivePenMode(activated: self.activePenModeSwitch.isOn)
        self.delegate?.didChangeActivePenMode(activated: self.activePenModeSwitch.isOn)
    }

    @IBAction private func undo(_ sender: Any) {
        self.delegate?.undo()
    }

    @IBAction private func redo(_ sender: Any) {
        self.delegate?.redo()
    }

    @IBAction private func clear(_ sender: Any) {
        self.delegate?.clear()
    }
}
