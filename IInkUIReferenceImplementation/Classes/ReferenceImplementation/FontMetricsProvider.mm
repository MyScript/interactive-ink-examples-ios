// Copyright MyScript. All right reserved.

#import "FontMetricsProvider.h"

#import "NSAttributedString+Helper.h"

@implementation FontMetricsProvider

- (NSArray *)getCharacterBoundingBoxes:(IINKText *)text spans:(NSArray *)spans
{
    NSAttributedString *attributedString = [NSAttributedString attributedStringWithText:text spans:spans];
    return [attributedString charactersBoundingBoxers];
}

- (float)getFontSizePx:(IINKStyle *)style
{
    return style.fontSize;
}

@end
