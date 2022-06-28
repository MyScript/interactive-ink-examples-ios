// Copyright @ MyScript. All rights reserved.

import Foundation

fileprivate let CACHE_MAX_BYTES = 200*1000000

/// The ImageLoader role is to load Images from a path

class ImageLoader: NSObject {

    private let cache: NSCache<AnyObject, NSData> = NSCache()

    override init() {
        super.init()
        self.cache.name = String(format: "Image Loader (%p)",self)
        self.cache.totalCostLimit = CACHE_MAX_BYTES
    }

    func imageData(from url: String) -> NSData? {
        var obj: NSData? = nil
        synchronized(self) {
            obj = self.cache.object(forKey: url as NSString)
            if obj == nil {
                obj = NSData(contentsOfFile: url)
                guard let objUnwrapped = obj else { return }
                self.cache.setObject(objUnwrapped, forKey: url as NSString, cost: objUnwrapped.length)
            }
        }
        return obj
    }
}
