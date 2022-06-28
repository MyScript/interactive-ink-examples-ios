// Copyright @ MyScript. All rights reserved.

import Foundation

/// Extension for CTRun that provides useful APIs

extension CTRun {

    var font: CTFont? {
        let cfRunAttributes = CTRunGetAttributes(self)
        guard let runAttributes = cfRunAttributes as? [CFString: Any],
              let font = runAttributes[kCTFontAttributeName] as? UIFont else {
            return nil
        }
        return font
    }

    func glyphs(in range: Range<Int> = 0..<0) -> [CGGlyph] {
        let count = range.isEmpty ? CTRunGetGlyphCount(self) : range.count
        var glyphs = Array(repeating: CGGlyph(), count: count)
        CTRunGetGlyphs(self, CFRangeMake(range.startIndex, range.count), &glyphs)
        return glyphs
    }

    func boundingRects(for glyphs: [CGGlyph], in font: CTFont) -> [CGRect] {
        var boundingRects = Array(repeating: CGRect(), count: glyphs.count)
        CTFontGetBoundingRectsForGlyphs(font, .default, glyphs, &boundingRects, glyphs.count)
        return boundingRects
    }

    func advances(for glyphs: [CGGlyph], in font: CTFont) -> [CGSize] {
        var advances = Array(repeating: CGSize(), count: glyphs.count)
        CTFontGetAdvancesForGlyphs(font, .default, glyphs, &advances, glyphs.count)
        return advances
    }

    func positions(in range: Range<Int> = 0..<0) -> [CGPoint] {
        let count = range.isEmpty ? CTRunGetGlyphCount(self) : range.count
        var positions = Array(repeating: CGPoint(), count: count)
        CTRunGetPositions(self, CFRangeMake(range.startIndex, range.count), &positions)
        return positions
    }
}
