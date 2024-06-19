// Copyright @ MyScript. All rights reserved.

import Foundation
import UIKit

/// The Canvas is the tool used by the RenderView to display a stroke. It handles all the settings of the CGContext, and the drawing commands.

@objcMembers class Canvas : NSObject {

    // MARK: - Properties

    var context:CGContext?
    var size:CGSize = CGSize.zero
    var clearAtStartDraw:Bool = true
    weak var imageLoader:ImageLoader?
    weak var offscreenRenderSurfaces:OffscreenRenderSurfaces?
    private var aTransform:CGAffineTransform = .identity
    private var style:IINKStyle = IINKStyle()
    private var clippedGroupIdentifier:[String] = []
    private var fontAttributeDict:[NSAttributedString.Key : Any] = [NSAttributedString.Key : Any]()
    private var cgRule:CGPathFillRule = .evenOdd
}

extension Canvas : IINKICanvas {

    // MARK: - Drawing Session Management

    func startDraw(in rect: CGRect) {
        if self.context == nil {
            self.context = UIGraphicsGetCurrentContext()
        }
        self.aTransform = .identity
        self.fontAttributeDict.removeAll()
        self.context?.saveGState()
        //Enforce defaults
        self.style.setAllChangeFlags()
        self.style.apply(to: self)
        self.style.clearChangeFlags()
        // Specific transform for text since we use CoreText to draw
        var transform:CGAffineTransform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -self.size.height)
        self.context?.textMatrix = transform
        self.context?.clip(to: rect)
        if self.clearAtStartDraw {
            self.context?.clear(rect)
        }
    }

    func endDraw() {
        self.context?.restoreGState()
    }

    // MARK: - View Properties

    func getTransform() -> CGAffineTransform {
        return self.aTransform
    }

    func setTransform(_ transform: CGAffineTransform) {
        let invertedTransform:CGAffineTransform = self.aTransform.inverted()
        let resultTransform:CGAffineTransform = transform.concatenating(invertedTransform)
        self.aTransform = transform
        self.context?.concatenate(resultTransform)
    }

    // MARK: - Stroking Properties

    func setStrokeColor(_ color: UInt32) {
        self.style.strokeColor = color
        self.context?.setStrokeColor(IInkUIRefImplUtils.uiColor(rgba: color).cgColor)
    }

    func setStrokeWidth(_ width: Float) {
        self.style.strokeWidth = width
        self.context?.setLineWidth(CGFloat(width))
    }

    func setStroke(_ lineCap: IINKLineCap) {
        style.strokeLineCap = lineCap
        switch lineCap {
        case .butt:
            self.context?.setLineCap(.butt)
            break
        case .round:
            self.context?.setLineCap(.round)
            break
        case .square:
            self.context?.setLineCap(.square)
            break
        default:
            break
        }
    }

    func setStroke(_ lineJoin: IINKLineJoin) {
        self.style.strokeLineJoin = lineJoin
        switch lineJoin {
        case .miter:
            self.context?.setLineJoin(.miter)
            break
        case .round:
            self.context?.setLineJoin(.round)
            break
        case .bevel:
            self.context?.setLineJoin(.bevel)
            break
        default:
            break
        }
    }

    func setStrokeMiterLimit(_ limit: Float) {
        self.style.strokeMiterLimit = limit
        self.context?.setMiterLimit(CGFloat(limit))
    }

    private func setLineDash() {
        let dashes:[CGFloat] = self.style.strokeDashArray.map{CGFloat($0.floatValue)}
        let offSet:CGFloat = dashes.count > 0 ? CGFloat(self.style.strokeDashOffset) : 0
        self.context?.setLineDash(phase: offSet, lengths: dashes)
    }

    func setStrokeDashArray(_ array: UnsafePointer<Float>?, size: Int) {
        var dashArray:[NSNumber] = [NSNumber]()
        if let array = array {
            // Must convert pointer to buffer before passing it to a swift Array
            let buffer:UnsafeBufferPointer<Float> = UnsafeBufferPointer<Float>(start: array, count: size)
            let swiftArray:[Float] = [Float](buffer)
            dashArray = swiftArray.map{NSNumber(value: $0)}
        }
        self.style.strokeDashArray = dashArray
        self.setLineDash()
    }

    func setStrokeDashOffset(_ offset: Float) {
        self.style.strokeDashOffset = offset
        self.setLineDash()
    }

    // MARK: - Filling Properties

    func setFillColor(_ color: UInt32) {
        self.style.fillColor = color
        self.context?.setFillColor(IInkUIRefImplUtils.uiColor(rgba: color).cgColor)
        self.fontAttributeDict[NSAttributedString.Key.foregroundColor] = IInkUIRefImplUtils.uiColor(rgba: color)
    }

    func setFillRule(_ rule: IINKFillRule) {
        self.style.fillRule = rule
        self.cgRule = rule == .evenOdd ? CGPathFillRule.evenOdd : CGPathFillRule.winding
    }

    // MARK: - Drop Shadow Properties

    func setDropShadow(_ xOffset: Float, yOffset: Float, radius: Float, color: UInt32) {
        if color != 0 {
            self.style.dropShadowXOffset = xOffset
            self.style.dropShadowYOffset = yOffset
            self.style.dropShadowRadius = radius
            self.style.dropShadowColor = color
            let size = CGSize(width: CGFloat(xOffset), height: CGFloat(yOffset))
            self.context?.setShadow(offset: size, blur: CGFloat(radius), color: IInkUIRefImplUtils.uiColor(rgba: color).cgColor)
        }
    }

    // MARK: - Font Properties

    func setFontProperties(_ family: String, height lineHeight: Float, size: Float, style: String, variant: String, weight: Int32) {
        self.style.fontFamily = family
        self.style.fontLineHeight = lineHeight
        self.style.fontSize = size
        self.style.fontVariant = variant
        self.style.fontWeight = Int(weight)
        self.style.fontStyle = style
        let font:UIFont? = UIFont.fontFromStyle(style: self.style)
        self.fontAttributeDict[NSAttributedString.Key.font] = font
        self.fontAttributeDict[NSAttributedString.Key.ligature] = NSNumber(0)
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(self.style.fontLineHeight)
        self.fontAttributeDict[NSAttributedString.Key.paragraphStyle] = paragraphStyle
    }

    // MARK: - Group Management

    func startGroup(_ identifier: String, region: CGRect, clip clipContent: Bool) {
        if clipContent {
            self.clippedGroupIdentifier.append(identifier)
            self.style.clearChangeFlags()
            self.context?.saveGState()
            self.context?.clip(to: CGRect(x: region.origin.x, y: region.origin.y, width: region.width, height: region.height))
        }
    }

    func endGroup(_ identifier: String) {
        if let i = self.clippedGroupIdentifier.lastIndex(of: identifier) {
            self.context?.restoreGState()
            self.style.apply(to: self)
            self.clippedGroupIdentifier.remove(at: i)
        }
    }

    func startItem(_ identifier: String) {

    }

    func endItem(_ identifier: String) {

    }

    // MARK: - Drawing commands

    func createPath() -> IINKIPath {
        return Path()
    }

    func draw(_ path: IINKIPath) {
        guard let aPath:Path = path as? Path else { return }
        if IInkUIRefImplUtils.alphaComponentFromColor(colorInt32: self.style.fillColor) > 0 {
            self.context?.addPath(aPath.bezierPath.cgPath)
            self.context?.fillPath(using: self.cgRule)
        }
        if IInkUIRefImplUtils.alphaComponentFromColor(colorInt32: self.style.strokeColor) > 0 {
            self.context?.addPath(aPath.bezierPath.cgPath)
            self.context?.strokePath()
        }
    }

    func drawRectangle(_ rect: CGRect) {
        if IInkUIRefImplUtils .alphaComponentFromColor(colorInt32: self.style.fillColor) > 0 {
            self.context?.fill(rect)
        }
        if IInkUIRefImplUtils .alphaComponentFromColor(colorInt32: self.style.strokeColor) > 0 {
            self.context?.stroke(rect)
        }
    }

    func drawLine(_ from: CGPoint, to: CGPoint) {
        self.context?.move(to: from)
        self.context?.addLine(to: to)
        self.context?.strokePath()
    }

    func drawObject(_ url: String, mimeType: String, region rect: CGRect) {
        guard let imageData: Data = self.imageLoader?.imageData(from: url) as Data?,
              let image: UIImage = UIImage(data: imageData),
              let cgImage = image.cgImage,
              mimeType.contains("image") else {
            return
        }
        self.context?.saveGState()
        // flip the image around the y axis, as images must be drawn updside down on iOS
        // 1. translate the context so that image is split in 2 equal parts by the X axis
        // 2. scale the context by y = -1 to put the image upside down
        // 3. translate the context so that image is back to its original position
        self.context?.translateBy(x: 0, y: rect.origin.y + rect.height / 2)
        self.context?.scaleBy(x: 1, y: -1)
        self.context?.translateBy(x: 0, y: -1 * (rect.origin.y + rect.height / 2))
        self.context?.draw(cgImage, in: rect)
        self.context?.restoreGState()
    }

    func drawText(_ label: String, anchor origin: CGPoint, region rect: CGRect) {
        guard let context = self.context,
              let font = UIFont.fontFromStyle(style: self.style,string: label) else {
                  return
        }
        self.fontAttributeDict[NSAttributedString.Key.font] = font
        let attrString:NSAttributedString = NSAttributedString(string: label, attributes: self.fontAttributeDict)
        let line:CTLine = CTLineCreateWithAttributedString(attrString)
        self.context?.textPosition = origin
        CTLineDraw(line, context)
    }

    func blendOffscreen(_ offscreenId: UInt32, src: CGRect, dest: CGRect, color: UInt32) {
        guard let buffer:CGLayer = self.offscreenRenderSurfaces?.getSurfaceBuffer(forId: offscreenId), let scale = self.offscreenRenderSurfaces?.scale else { return }
        let size = buffer.size

        self.context?.saveGState()
        self.context?.clip(to: dest)
        let alpha:CGFloat = CGFloat(color & 0xff) / 255.0
        self.context?.setAlpha(alpha)
        let src_ = CGRect(x: src.origin.x * scale, y: src.origin.y * scale, width: src.width * scale, height: src.height * scale)
        let x:CGFloat = dest.origin.x - src_.origin.x / src_.size.width * dest.size.width
        let y:CGFloat = dest.origin.y - src_.origin.y / src_.size.height * dest.size.height
        let width:CGFloat = size.width / src_.size.width * dest.size.width
        let height:CGFloat = size.height / src_.size.height * dest.size.height
        self.context?.draw(buffer, in: CGRect(x: x, y: y, width: width, height: height))
        self.context?.restoreGState()
    }
}
