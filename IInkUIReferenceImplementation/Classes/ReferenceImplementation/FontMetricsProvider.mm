// Copyright MyScript. All right reserved.

#import "FontMetricsProvider.h"

#import <CoreText/CoreText.h>
#import "NSAttributedString+Helper.h"
#import "UIfont+Helper.h"

@implementation FontMetricsProvider

- (NSArray<NSValue *> *)getCharacterBoundingBoxes:(IINKText *)text spans:(NSArray *)spans
{
    NSArray<NSValue *> *glyphMetrics = [self getGlyphMetrics:text spans:spans];
    NSMutableArray<NSValue *> *charBoxes = [[NSMutableArray alloc] initWithCapacity:glyphMetrics.count];
    for (NSUInteger i = 0, n = glyphMetrics.count; i < n; ++i)
    {
        IINKGlyphMetrics metrics;
        [glyphMetrics[i] getValue:&metrics];
        charBoxes[i] = [NSValue valueWithCGRect:metrics.boundingBox];
    }
    return charBoxes;
}

- (float)getFontSizePx:(IINKStyle *)style
{
    return style.fontSize;
}

- (NSArray<NSValue *> *)getGlyphMetrics:(IINKText *)text spans:(NSArray<IINKTextSpan *> *)spans
{
    NSAttributedString *attributedString = [NSAttributedString attributedStringWithText:text spans:spans];

    NSMutableArray<NSValue *> *glyphMetrics = [[NSMutableArray alloc] initWithCapacity:attributedString.length];

    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);

    CFIndex runCount = CFArrayGetCount(runArray);
    int globalGlyphIndex = 0;
    for (int runIndex = 0; runIndex < runCount; ++runIndex)
    {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);

        CFDictionaryRef dict = CTRunGetAttributes(run);
        UIFont* font = (UIFont*)CFDictionaryGetValue(dict, kCTFontAttributeName);
        CTFontRef ctfont = CTFontCreateWithName((CFStringRef)[font fontName], [font pointSize], NULL);

        CFIndex glyphCount = CTRunGetGlyphCount(run);

        CGGlyph glyphs[glyphCount];
        CFRange range = CFRangeMake(0, 0);
        CTRunGetGlyphs(run, range, glyphs);

        CGPoint positions[glyphCount];
        CTRunGetPositions(run, range, positions);

        CGRect boundingRects[glyphCount];
        CTFontGetBoundingRectsForGlyphs(ctfont, kCTFontOrientationDefault, glyphs, boundingRects, glyphCount);

        CGSize advances[glyphCount];
        CTFontGetAdvancesForGlyphs(ctfont, kCTFontOrientationDefault, glyphs, advances, glyphCount);

        for (int glyphIndex = 0; glyphIndex < glyphCount; ++glyphIndex)
        {
            CGPoint origin = boundingRects[glyphIndex].origin;
            CGSize size = boundingRects[glyphIndex].size;
            CGPoint position = positions[glyphIndex];
            CGSize advance = advances[glyphIndex];

            IINKGlyphMetrics metrics;
            metrics.boundingBox.origin.x = position.x + origin.x;
            metrics.boundingBox.origin.y = -origin.y - size.height;
            metrics.boundingBox.size.width = size.width;
            metrics.boundingBox.size.height = size.height;
            metrics.leftSideBearing = -origin.x;
            metrics.rightSideBearing = advance.width - (origin.x + size.width);

            glyphMetrics[globalGlyphIndex] = [NSValue valueWithBytes:&metrics objCType:@encode(IINKGlyphMetrics)];
            ++globalGlyphIndex;
        }
    }

    CFRelease(line);

    return glyphMetrics;
}

@end
