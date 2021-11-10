// Copyright @ MyScript. All rights reserved.

import Foundation

fileprivate let CACHE_MAX_BYTES = 200*1000000

/// The ImageLoader role is to load Images from a path

class ImageLoader : NSObject {

    private let cache:NSCache<AnyObject, NSData> = NSCache()

    override init() {
        super.init()
        self.cache.totalCostLimit = CACHE_MAX_BYTES
    }

    func image(fromURL:NSString) -> NSData? {
        self.cache.name = String(format:"Image Loader (%p)",self)
        var obj:NSData? = nil
        synchronized(self) {
            obj = self.cache.object(forKey: fromURL)
            if obj == nil {
                obj = NSData(contentsOfFile: fromURL as String)
                guard let objUnwrapped = obj else { return }
                self.cache.setObject(objUnwrapped, forKey: fromURL, cost: objUnwrapped.length)
            }
        }
        return obj
    }
}
