// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

struct OffscreenRenderSurface {
    var context:CGContext
    var data:UnsafeMutableRawPointer
    var size:CGSize
}

/// The OffscreenRenderSurfaces role is to manage the content blocks not currently displayed on the screen. It adds and releases surfaces on the need. It is important to understand that the addSurface/getSurface/ReleaseSurface methods can be called very often, so we must always wait that a call is finished before making another one, in order not to mix the ids. Hence the use of the "synchronized" utiliy class

class OffscreenRenderSurfaces : NSObject {

    // MARK: - Properties

    @objc var scale:CGFloat = 1
    private var buffers:[NSNumber:OffscreenRenderSurface] = [NSNumber:OffscreenRenderSurface]()
    private var nextId:UInt32 = 0

    // MARK: - Methods

    @objc func addSurface(width:Int, height:Int) -> UInt32 {
        let bytesPerRow = 4 * width
        let dataSize = bytesPerRow * height
        let data = UnsafeMutableRawPointer.allocate(byteCount: dataSize, alignment: MemoryLayout<UInt8>.alignment)
        data.initializeMemory(as: UInt8.self, repeating: 0, count: dataSize)

        guard let context = CGContext(data: data,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
            data.deallocate()
            return 0
        }

        return synchronized(lock: self) {
            let surface = OffscreenRenderSurface(context: context, data: data, size: CGSize(width: width, height: height))
            nextId += 1
            let key:NSNumber = NSNumber(value: self.nextId)
            self.buffers[key] = surface
            return nextId
        }
    }

    @objc func getSurfaceContext(forId offscreenId:UInt32) -> CGContext? {
        let key:NSNumber = NSNumber(value: offscreenId)
        var surface:OffscreenRenderSurface?
        synchronized(self) {
            surface = buffers[key]
        }
        return surface?.context
    }

    func getSurfaceSize(forId offscreenId:UInt32) -> CGSize {
        let key:NSNumber = NSNumber(value: offscreenId)
        var surface:OffscreenRenderSurface?
        synchronized(self) {
            surface = buffers[key]
        }
        return surface?.size ?? .zero
    }

    @objc func releaseSurface(forId offscreenId:UInt32) {
        let key:NSNumber = NSNumber(value: offscreenId)
        synchronized(self) {
            if let surface = buffers.removeValue(forKey: key) {
                surface.data.deallocate()
            }
        }
    }
}
