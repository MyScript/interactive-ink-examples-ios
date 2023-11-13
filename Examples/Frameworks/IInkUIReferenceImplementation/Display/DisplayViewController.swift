// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit
import Combine

/// The DisplayViewController role is to display all the strokes. It contains the capture RenderView (which displays live capturing stroke), and the model RenderView (which displays the recorded strokes).

class DisplayViewController:UIViewController {

    static let keyPathObserved = "view.layer.bounds"
    static let refreshNotification = Notification.Name("refreshNotification")

    //MARK: - Properties

    private var viewModel:DisplayViewModel
    private var cancellables: Set<AnyCancellable> = []

    //MARK: - Life cycle

    init(viewModel:DisplayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView(frame: CGRect.zero)
        self.view.backgroundColor = UIColor.clear
        self.bindViewModel()
        self.viewModel.setOffScreenRendererSurfacesScale(scale: self.view.contentScaleFactor)
        self.viewModel.setupModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserver(self, forKeyPath: DisplayViewController.keyPathObserved, options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDisplay), name: DisplayViewController.refreshNotification, object: nil)
    }

    //MARK: - UI settings

    private func displayModel(model:DisplayModel) {
        self.configureRenderView(renderView: model.renderView)
        self.viewModel.refreshDisplay()
    }

    private func configureRenderView(renderView:RenderView) {
        self.view.addSubview(renderView)
        renderView.translatesAutoresizingMaskIntoConstraints = false
        renderView.backgroundColor = UIColor.clear
        renderView.isOpaque = false
    }

    override func updateViewConstraints() {
        self.viewModel.initModelViewConstraints(view: self.view)
        super.updateViewConstraints()
    }

    @objc func refreshDisplay() {
        self.viewModel.refreshDisplay()
    }

    //MARK: - KVO

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == DisplayViewController.keyPathObserved {
            self.viewModel.refreshDisplay()
        }
    }

    //MARK: - Data Binding

    private func bindViewModel() {
        self.viewModel.$model.sink { [weak self] model in
            if let model = model {
                self?.displayModel(model:model)
            }
        }.store(in: &cancellables)
    }
}
