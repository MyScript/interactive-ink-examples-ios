// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// The ImageDrawer role is to create Images when the user wants to Export a document.

class ImageDrawer : IINKRenderer {
    let imageLoader : ImageLoader
    var backgroundColor : UIColor?
    private var imageSize:CGSize?

    init(imageLoader:ImageLoader) {
        self.imageLoader = imageLoader
    }
}

extension ImageDrawer : IINKIImageDrawer {

    func prepareImage(_ size: CGSize) {
        self.imageSize = size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
    }

    func saveImage(_ path: String) {
        defer { UIGraphicsEndImageContext() }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        let pathNS = path as NSString
        let ext:String = pathNS.pathExtension
        var mime:IINKMimeType?
        if ext == "jpeg" || ext == "jpg" || ext == "jpe"  {
            mime = .JPEG
        } else if ext == "png" {
            mime = .PNG
        }
        var imageData:Data?
        switch mime {
        case .JPEG:
            imageData = image.jpegData(compressionQuality: 1)
            break
        case .PNG:
            imageData = image.pngData()
            break
        default:
            break
        }
        do {
            try imageData?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch { // Error not catched for now
            print (error)
        }
    }

    func invalidate(_ renderer: IINKRenderer, layers: IINKLayerType) {
        guard let imageSize = imageSize else { return }
        self.invalidate(renderer, area: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), layers: layers)
    }

    func invalidate(_ renderer: IINKRenderer, area: CGRect, layers: IINKLayerType) {
        guard let context:CGContext = UIGraphicsGetCurrentContext(), let imageSize = self.imageSize else { return }
        let canvas:Canvas = Canvas()
        canvas.imageLoader = self.imageLoader
        let transform:CGAffineTransform = CGAffineTransform(scaleX: 1, y: -1)
        transform.translatedBy(x: 0, y: imageSize.height)
        if let backgroundColor = self.backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
        }
        if ((layers.rawValue & IINKLayerType.capture.rawValue) != 0) {
            context.saveGState()
            context.textMatrix = transform
            renderer.drawCaptureStrokes(area, canvas: canvas)
            context.restoreGState()
        }
        if ((layers.rawValue & IINKLayerType.model.rawValue) != 0) {
            context.saveGState()
            context.textMatrix = transform
            renderer.drawModel(area, canvas: canvas)
            context.restoreGState()
        }
    }
}
