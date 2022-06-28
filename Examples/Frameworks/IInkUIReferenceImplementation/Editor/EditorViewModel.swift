// Copyright @ MyScript. All rights reserved.

import Combine
import UIKit

protocol EditorDelegate: AnyObject {
    func didCreateEditor(editor: IINKEditor?)
}

/// This class is the ViewModel of the EditorViewController. It handles all its business logic.

class EditorViewModel {

    //MARK: - Reactive Properties

    @Published var inputMode: InputMode = .forcePen
    @Published var model: EditorModel?

    //MARK: - Properties

    var editor: IINKEditor?
    private weak var engine: IINKEngine?
    private(set) var originalViewOffset: CGPoint = CGPoint.zero
    private weak var editorDelegate: EditorDelegate?
    private weak var smartGuideDelegate: SmartGuideViewControllerDelegate?
    private var smartGuideDisabled: Bool = false
    private var didSetConstraints: Bool = false

    init(engine: IINKEngine?,
         inputMode: InputMode,
         editorDelegate: EditorDelegate?,
         smartGuideDelegate: SmartGuideViewControllerDelegate?,
         smartGuideDisabled: Bool = false) {
        self.engine = engine
        self.inputMode = inputMode
        self.editorDelegate = editorDelegate
        self.smartGuideDelegate = smartGuideDelegate
    }

    func setupModel(with panGesture: UIPanGestureRecognizer?) {
        let model = EditorModel()
        let displayViewModel = DisplayViewModel()
        self.initEditor(with: displayViewModel)
        model.displayViewController = DisplayViewController(viewModel: displayViewModel)
        if self.smartGuideDisabled == false {
            model.smartGuideViewController = SmartGuideViewController()
            model.smartGuideViewController?.editor = self.editor
            model.smartGuideViewController?.delegate = self.smartGuideDelegate
        }
        model.neboInputView = InputView(frame: CGRect.zero)
        model.neboInputView?.inputMode = self.inputMode
        model.neboInputView?.editor = self.editor
        if let panGesture = panGesture {
            model.neboInputView?.addGestureRecognizer(panGesture)
        }
        self.model = model
    }

    func updateInputMode(newInputMode: InputMode) {
        self.inputMode = newInputMode
        self.model?.neboInputView?.inputMode = inputMode
    }

    func configureEditorUI(with viewSize: CGSize) {
        guard let editor = self.editor else {
            return
        }
        try? editor.set(viewSize: viewSize)
        let conf: IINKConfiguration = editor.configuration
        let horizontalMarginMM: Double = 5
        let verticalMarginMM: Double = 15

        try? conf.set(number: verticalMarginMM, forKey: "text.margin.top")
        try? conf.set(number: horizontalMarginMM, forKey: "text.margin.left")
        try? conf.set(number: horizontalMarginMM, forKey: "text.margin.right")
        try? conf.set(number: verticalMarginMM, forKey: "math.margin.top")
        try? conf.set(number: verticalMarginMM, forKey: "math.margin.bottom")
        try? conf.set(number: horizontalMarginMM, forKey: "math.margin.left")
        try? conf.set(number: horizontalMarginMM, forKey: "math.margin.right")
    }

    func initModelViewConstraints(view: UIView, containerView: UIView) {
        guard self.didSetConstraints == false,
              let model = self.model,
              let displayViewController = model.displayViewController,
              let displayViewControllerView = displayViewController.view,
              let inputView = model.neboInputView else {
                  return
              }
        self.didSetConstraints = true
        let views:[String : Any] = ["containerView": containerView, "displayViewControllerView": displayViewControllerView, "inputView": inputView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[inputView]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[inputView]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[displayViewControllerView]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[displayViewControllerView]|", options: .alignAllLeft, metrics: nil, views: views))
    }

    func handlePanGestureRecognizerAction(with translation: CGPoint, state: UIGestureRecognizer.State) {
        guard self.editor?.isScrollAllowed == true else {
            return
        }
        if state == UIGestureRecognizer.State.began {
            self.originalViewOffset = self.editor?.renderer.viewOffset ?? CGPoint.zero
        }
        var newOffset:CGPoint = CGPoint(x: originalViewOffset.x - translation.x, y: originalViewOffset.y - translation.y)
        self.editor?.clampViewOffset(&newOffset)
        self.editor?.renderer.viewOffset = newOffset
        if state == UIGestureRecognizer.State.ended {
            self.originalViewOffset = self.editor?.renderer.viewOffset ?? CGPoint.zero
        }
        NotificationCenter.default.post(name: DisplayViewController.refreshNotification, object: nil)
    }

    func setEditorViewSize(size: CGSize) {
        try? self.editor?.set(viewSize: size)
    }

    private func initEditor(with target: DisplayViewModel) {
        guard let engine = self.engine,
              let renderer = try? engine.createRenderer(dpiX: Helper.scaledDpi(),
                                                        dpiY: Helper.scaledDpi(),
                                                        target: target) else {
                  return
              }
        let toolController: IINKToolController = engine.createToolController()
        self.editor = self.engine?.createEditor(renderer: renderer,
                                                toolController: toolController)

        // Apply theme from css file if any
        if let path = Bundle.main.path(forResource: "theme", ofType: "css"),
           let cssString = try? String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines) {
            try? self.editor?.set(theme: cssString)
        }

        self.editor?.set(fontMetricsProvider: FontMetricsProvider())
        self.editorDelegate?.didCreateEditor(editor: self.editor)
        target.renderer = renderer
        target.imageLoader = ImageLoader()
    }
}
