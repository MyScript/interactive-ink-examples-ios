// Copyright @ MyScript. All rights reserved.

import Foundation

/// Workaround to make the objc @synchronized work in swift

func synchronized(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/// Workaround to make the objc @synchronized work in swift and also return a generic value

func synchronized<T>(lock: AnyObject, closure: () -> T) -> T {
  objc_sync_enter(lock)
  let retVal: T = closure()
  objc_sync_exit(lock)
  return retVal
}
