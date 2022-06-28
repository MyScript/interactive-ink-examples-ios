// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

enum InputMode : Int {
    case forcePen
    case forceTouch
    case auto
}

/// The InputView role is to capture all the touch events and follow them back to the editor so it can convert them to a stroke

class InputView : UIView {

    // MARK: - Properties

    weak var editor:IINKEditor?
    var inputMode:InputMode = .forcePen
    private var trackPressure:Bool = false
    private var cancelled:Bool = false
    private var touchesBegan:Bool = false
    private var eventTimeOffset:TimeInterval = 0

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
        self.isMultipleTouchEnabled = false
        self.trackPressure = self.traitCollection.forceTouchCapability == .available
        let rel_t:TimeInterval = ProcessInfo.processInfo.systemUptime
        let abs_t:TimeInterval = NSTimeIntervalSince1970
        self.eventTimeOffset = abs_t - rel_t
    }

    // MARK: - Touches

    private func pointerEvent(from touch:UITouch, eventType:IINKPointerEventType) -> IINKPointerEvent {
        var pointerType:IINKPointerType = .pen
        switch self.inputMode {
        case .forcePen:
            pointerType = .pen
            break
        case .forceTouch:
            pointerType = .touch
            break
        default:
            pointerType = touch.type == .stylus ? .pen : .touch
            break
        }
        var point:CGPoint = CGPoint.zero
        var f:Float = 0
        if touch.type == .stylus {
            point = touch.preciseLocation(in: self)
            f = Float(touch.force / touch.maximumPossibleForce)
        } else {
            point = touch.location(in: self)
        }
        let t:Int64 = Int64(1000*(touch.timestamp + self.eventTimeOffset))
        return IINKPointerEvent(eventType: eventType, x: Float(point.x), y: Float(point.y), t: t, f: f, pointerType: pointerType, pointerId: 0)
    }

    func pointerDownEvent(from touch:UITouch) -> IINKPointerEvent {
        return self.pointerEvent(from: touch, eventType: .down)
    }

    func pointerMoveEvent(from touch:UITouch) -> IINKPointerEvent {
        return self.pointerEvent(from: touch, eventType: .move)
    }

    func pointerUpEvent(from touch:UITouch) -> IINKPointerEvent {
        return self.pointerEvent(from: touch, eventType: .up)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch:UITouch = touches.randomElement() else { return }
        let e:IINKPointerEvent = self.pointerDownEvent(from: touch)
        if e.pointerType == .pen {
            self.touchesBegan = true
        }
        let point = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y))
        let _ = try? self.editor?.pointerDown(point: point, timestamp: e.t, force: e.f, type: e.pointerType, pointerId: Int(e.pointerId))
        self.cancelled = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch:UITouch = touches.randomElement() else { return }
        let coalescedTouches:[UITouch]? = event?.coalescedTouches(for: touch)
        if let coalescedTouchesUnwrapped = coalescedTouches {
            var events:[IINKPointerEvent] = coalescedTouchesUnwrapped.map { coalescedTouch in
                self.pointerMoveEvent(from: coalescedTouch)
            }
            let pointerEvent:UnsafeMutablePointer<IINKPointerEvent> = UnsafeMutablePointer<IINKPointerEvent>.allocate(capacity: events.count)
            pointerEvent.initialize(from: &events, count: events.count)
            do {
                try self.editor?.pointerEvents(pointerEvent, count: events.count, doProcessGestures: true)
            } catch { // Error not catched for now
                print(error)
            }
        } else {
            let e:IINKPointerEvent = self.pointerMoveEvent(from: touch)
            do {
                try self.editor?.pointerMove(point: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y)), timestamp: e.t, force: e.f, type: e.pointerType, pointerId: Int(e.pointerId))
            } catch { // Error not catched for now
                print(error)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch:UITouch = touches.randomElement() else { return }
        let e:IINKPointerEvent = self.pointerUpEvent(from: touch)
        do {
            try self.editor?.pointerUp(point: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y)), timestamp: e.t, force: e.f, type: e.pointerType, pointerId: Int(e.pointerId))
        } catch { // Error not catched for now
            print(error)
        }
        self.touchesBegan = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        do {
            try self.editor?.pointerCancel(0)
        } catch { // Error not catched for now
            print(error)
        }
        self.cancelled = true
        self.touchesBegan = false
    }
}
