// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// The RenderView role is to render (hence its name) the different strokes, using a Canvas and a Renderer. For performance reasons, there are two types of RenderView, layer or capture. One is used to display live capturing stroke, and the other is used to diplay the recorded strokes (the model).

class RenderView : UIView {

    // MARK: - Properties

    weak var renderer:IINKRenderer?
    weak var imageLoader:ImageLoader? {
        didSet {
            self.canvas.imageLoader = self.imageLoader
        }
    }
    weak var offscreenRenderSurfaces:OffscreenRenderSurfaces? {
        didSet {
            self.canvas.offscreenRenderSurfaces = self.offscreenRenderSurfaces
        }
    }
    private var canvas:Canvas = Canvas()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ownInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.ownInit()
    }

    private func ownInit() {
        self.layer.drawsAsynchronously = true
    }

    // MARK: - Drawing

    override func layerWillDraw(_ layer: CALayer) {
        // 8-bit sRGB (probably fine unless there’s wide color content)
        self.layer.contentsFormat = CALayerContentsFormat.RGBA8Uint
    }

    override func draw(_ rect: CGRect) {
        self.canvas.context = UIGraphicsGetCurrentContext()
        self.canvas.size = self.bounds.size
        self.canvas.clearAtStartDraw = false
        self.renderer?.drawModel(rect, canvas: self.canvas)
        self.renderer?.drawCaptureStrokes(rect, canvas: self.canvas)
    }
}
