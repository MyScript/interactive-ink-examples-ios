// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// Stroke Paths Utils

class Path : NSObject, IINKIPath {

    var bezierPath:UIBezierPath = UIBezierPath()

    func move(to position: CGPoint) {
        bezierPath.move(to: position)
    }

    func line(to position: CGPoint) {
        bezierPath.addLine(to: position)
    }

    func close() {
        bezierPath.close()
    }

    func curve(to: CGPoint, controlPoint1 c1: CGPoint, controlPoint2 c2: CGPoint) {
        bezierPath.addCurve(to: to, controlPoint1: c1, controlPoint2: c2)
    }

    func quad(to: CGPoint, controlPoint c: CGPoint) {
        bezierPath.addQuadCurve(to: to, controlPoint: c)
    }
}
