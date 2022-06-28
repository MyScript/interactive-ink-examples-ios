// Copyright @ MyScript. All rights reserved.

import Foundation
import CoreText

/// The FontMetricsProvider class implements IINKIFontMetricsProvider protocol. It permits to get metrics in order to render glyphs correctly

class FontMetricsProvider : NSObject {

}

extension FontMetricsProvider : IINKIFontMetricsProvider {

    func getCharacterBoundingBoxes(_ text: IINKText!, spans: [IINKTextSpan]!) -> [NSValue]! {
        var charBoxes = [NSValue]()
        guard let glyphMetrics = self.getGlyphMetrics(text, spans: spans) else {
            return charBoxes
        }
        for glyphMetric in glyphMetrics {
            charBoxes.append(NSValue(cgRect: glyphMetric.boundingBox))
        }
        return charBoxes
    }

    func getFontSizePx(_ style: IINKStyle!) -> Float {
        return style.fontSize
    }

    func getGlyphMetrics(_ text: IINKText!, spans: [IINKTextSpan]!) -> [IINKGlyphMetrics]! {
        var glyphMetrics = [IINKGlyphMetrics]()
        let attributedString = NSAttributedString.attributedString(text: text, spans: spans)
        let line = CTLineCreateWithAttributedString(attributedString)
        let cfLineRuns = CTLineGetGlyphRuns(line)
        guard let lineRuns = cfLineRuns as? [CTRun] else {
            return glyphMetrics
        }
        for run in lineRuns {
            if let font = run.font {
                let glyphsCount = CTRunGetGlyphCount(run)
                let glyphs = run.glyphs()
                let boundingRects = run.boundingRects(for: glyphs, in: font)
                let advances = run.advances(for: glyphs, in: font)
                let positions = run.positions()
                // Loop on Glyphs to get metrics
                for i in 0..<glyphsCount {
                    let origin = boundingRects[i].origin
                    let size = boundingRects[i].size
                    let position = positions[i]
                    let advance = advances[i]
                    let metrics = IINKGlyphMetrics()
                    metrics.boundingBox.origin.x = position.x + origin.x
                    metrics.boundingBox.origin.y = -origin.y - size.height
                    metrics.boundingBox.size.width = size.width
                    metrics.boundingBox.size.height = size.height
                    metrics.leftSideBearing = -origin.x
                    metrics.rightSideBearing = advance.width - (origin.x + size.width)
                    glyphMetrics.append(metrics)
                }
            }
        }
        return glyphMetrics
    }
}
