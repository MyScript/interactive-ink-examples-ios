// Copyright MyScript. All right reserved.

#import "FontMetricsProvider.h"

#import "NSAttributedString+Helper.h"

@implementation FontMetricsProvider

- (NSArray *)getCharacterBoundingBoxes:(IINKText *)text spans:(NSArray *)spans
{
    NSAttributedString *attributedString = [NSAttributedString attributedStringWithText:text spans:spans];
    return [attributedString charactersBoundingBoxes];
}

- (float)getFontSizePx:(IINKStyle *)style
{
    return style.fontSize;
}

- (NSArray<NSValue *> *)getGlyphMetrics:(IINKText *)text spans:(NSArray<IINKTextSpan *> *)spans
{
    NSAttributedString *attributedString = [NSAttributedString attributedStringWithText:text spans:spans];
    return [attributedString glyphMetrics];
}

@end
