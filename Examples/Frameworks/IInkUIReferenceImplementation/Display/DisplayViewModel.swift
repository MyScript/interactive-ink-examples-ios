// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit
import Combine

/// This class is the ViewModel of the DisplayViewController. It handles all its business logic.

class DisplayViewModel : NSObject {

    //MARK: - Reactive Properties

    @Published var model:DisplayModel?

    //MARK: - Properties

    var renderer: IINKRenderer?
    var imageLoader: ImageLoader?
    private(set) var offscreenRenderSurfaces: OffscreenRenderSurfaces = OffscreenRenderSurfaces()
    private var didSetConstraints: Bool = false

    func setupModel() {
        let model: DisplayModel = DisplayModel()
        model.renderView.offscreenRenderSurfaces = offscreenRenderSurfaces
        if let renderer {
            model.renderView.renderer = renderer
        }
        if let imageLoader {
            model.renderView.imageLoader = imageLoader
        }
        self.model = model
    }

    func setOffScreenRendererSurfacesScale(scale:CGFloat) {
        self.offscreenRenderSurfaces.scale = scale
    }

    func initModelViewConstraints(view:UIView) {
        guard self.didSetConstraints == false, let model = self.model else { return }
        self.didSetConstraints = true
        let views: [String: RenderView] = ["renderView" : model.renderView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[renderView]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[renderView]|", options: .alignAllLeft, metrics: nil, views: views))
    }

    func refreshDisplay() {
        self.model?.renderView.setNeedsDisplay()
    }
}

extension DisplayViewModel : IINKIRenderTarget {

    func invalidate(_ renderer: IINKRenderer, layers: IINKLayerType) {
        DispatchQueue.main.async { [weak self] in
            self?.model?.renderView.setNeedsDisplay()
        }
    }

    func invalidate(_ renderer: IINKRenderer, area: CGRect, layers: IINKLayerType) {
        DispatchQueue.main.async { [weak self] in
            self?.model?.renderView.setNeedsDisplay(area)
        }
    }

    func createOffscreenRenderSurface(width: Int32, height: Int32, alphaMask: Bool) -> UInt32 {
        let scale:CGFloat = self.offscreenRenderSurfaces.scale
        let pixelWidth = Int(scale * CGFloat(width))
        let pixelHeight = Int(scale * CGFloat(height))
        return self.offscreenRenderSurfaces.addSurface(width: pixelWidth, height: pixelHeight)
    }

    func releaseOffscreenRenderSurface(_ surfaceId: UInt32) {
        self.offscreenRenderSurfaces.releaseSurface(forId: surfaceId)
    }

    func createOffscreenRenderCanvas(_ surfaceId: UInt32) -> IINKICanvas {
        let canvas = Canvas()
        var pixelSize:CGSize = CGSize.zero
        if let surfaceContext = self.offscreenRenderSurfaces.getSurfaceContext(forId: surfaceId) {
            pixelSize = self.offscreenRenderSurfaces.getSurfaceSize(forId: surfaceId)
            canvas.context = surfaceContext
        }
        let scale:CGFloat = offscreenRenderSurfaces.scale
        let size = CGSize(width: pixelSize.width / scale, height: pixelSize.height / scale)
        canvas.offscreenRenderSurfaces = self.offscreenRenderSurfaces
        canvas.imageLoader = self.imageLoader
        canvas.context?.saveGState()
        canvas.size = size
        return canvas
    }

    func releaseOffscreenRenderCanvas(_ canvas: IINKICanvas) {
        if let canvasCast:Canvas = canvas as? Canvas {
            canvasCast.context?.restoreGState()
        }
    }

    var pixelDensity: Float {
        return Float(UIScreen.main.scale)
    }
}
