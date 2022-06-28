// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// The ImagePainter role is to create Images when the user wants to Export a document.

class ImagePainter: IINKRenderer {
    let imageLoader: ImageLoader
    var backgroundColor: UIColor?
    private var imageSize: CGSize?
    private var canvas: Canvas?

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }
}

extension ImagePainter: IINKIImagePainter {

    func prepareImage(_ size: CGSize, dpi: Float) {
        self.imageSize = size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
    }

    func createCanvas() -> IINKICanvas {
        let canvas = Canvas()
        canvas.imageLoader = self.imageLoader
        return canvas
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
}
