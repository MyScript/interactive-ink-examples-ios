// Copyright @ MyScript. All rights reserved.

import Foundation
import Combine

protocol ToolStyleProtocol: AnyObject {
    func didSelectStyle(style: ToolStyleModel)
}

class ToolStyleViewController: UIViewController, Storyboarded {

    @IBOutlet private weak var colorLabel: UILabel!
    @IBOutlet private weak var color1Button: UIButton!
    @IBOutlet private weak var color2Button: UIButton!
    @IBOutlet private weak var color3Button: UIButton!
    @IBOutlet private weak var color4Button: UIButton!
    @IBOutlet private weak var widthLabel: UILabel!
    @IBOutlet private weak var widthSegmentedControl: UISegmentedControl!

    // MARK: Properties

    private weak var delegate:ToolStyleProtocol?
    private var viewModel: ToolStyleViewModel?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Life Cycle

    static func instantiate(tool: IINKPointerTool, toolStyle: ToolStyleModel, delegate: ToolStyleProtocol) -> Self? {
        let toolStyleVC = instantiate(from: .toolbar)
        toolStyleVC?.viewModel = ToolStyleViewModel(tool: tool, toolStyle: toolStyle)
        toolStyleVC?.delegate = delegate
        return toolStyleVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.viewModel?.setup()
    }

    // MARK: Data Binding

    private func bindViewModel() {
        // Color Buttons Models
        self.viewModel?.$color1ButtonModel.removeDuplicates().sink { [weak color1Button] model in
            if let model = model {
                color1Button?.layer.cornerRadius = model.radius
                color1Button?.backgroundColor = model.color
                color1Button?.layer.borderColor = model.borderColor
                color1Button?.layer.borderWidth = model.borderWidth
            }
        }.store(in: &cancellables)
        self.viewModel?.$color2ButtonModel.removeDuplicates().sink { [weak color2Button] model in
            if let model = model {
                color2Button?.layer.cornerRadius = model.radius
                color2Button?.backgroundColor = model.color
                color2Button?.layer.borderColor = model.borderColor
                color2Button?.layer.borderWidth = model.borderWidth
            }
        }.store(in: &cancellables)
        self.viewModel?.$color3ButtonModel.removeDuplicates().sink { [weak color3Button] model in
            if let model = model {
                color3Button?.layer.cornerRadius = model.radius
                color3Button?.backgroundColor = model.color
                color3Button?.layer.borderColor = model.borderColor
                color3Button?.layer.borderWidth = model.borderWidth
            }
        }.store(in: &cancellables)
        self.viewModel?.$color4ButtonModel.removeDuplicates().sink { [weak color4Button] model in
            if let model = model {
                color4Button?.layer.cornerRadius = model.radius
                color4Button?.backgroundColor = model.color
                color4Button?.layer.borderColor = model.borderColor
                color4Button?.layer.borderWidth = model.borderWidth
            }
        }.store(in: &cancellables)
        self.viewModel?.$widthSegmentedControlModel.removeDuplicates().sink { [weak widthSegmentedControl] model in
            if let model = model {
                widthSegmentedControl?.selectedSegmentIndex = model.selectedSegment
            }
        }.store(in: &cancellables)

        // New style state
        self.viewModel?.$futureStyleModel.removeDuplicates().sink { [weak self] model in
            if let model = model {
                self?.delegate?.didSelectStyle(style: model)
            }
        }.store(in: &cancellables)
    }

    // MARK: Actions

    @IBAction private func selectColor1(_ sender: Any) {
        self.viewModel?.selectColor1()
    }

    @IBAction private func selectColor2(_ sender: Any) {
        self.viewModel?.selectColor2()
    }

    @IBAction private func selectColor3(_ sender: Any) {
        self.viewModel?.selectColor3()
    }

    @IBAction private func selectColor4(_ sender: Any) {
        self.viewModel?.selectColor4()
    }

    @IBAction private func widthSegmentedControlValueChanged(_ sender: Any) {
        let newIndex = self.widthSegmentedControl.selectedSegmentIndex
        self.viewModel?.widthSegmentedControlValueChanged(newIndex: newIndex)
    }
}
