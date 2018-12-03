// Copyright MyScript. All right reserved.

#import "NSAttributedString+Helper.h"
#import <CoreText/CoreText.h>
#import <iink/text/IINKText.h>
#import <iink/text/IINKIFontMetricsProvider.h>
#import <iink/text/IINKTextSpan.h>
#import "UIfont+Helper.h"

@implementation NSAttributedString (Helper)

+ (NSAttributedString *)attributedStringWithText:(IINKText *)label
                                          spans:(NSArray<IINKTextSpan *> *)spans
{
    NSMutableAttributedString *completeAttributedString = [[NSMutableAttributedString alloc] initWithString:label.label];
    
    
    // Construct the line with all styles inside
    for (int index = 0; index < (int)spans.count; ++index)
    {
        IINKTextSpan *span = spans[index];

        NSInteger begin = [label getGlyphUtf16BeginAt:span.beginPosition error:nil];
        NSInteger end = [label getGlyphUtf16EndAt:span.endPosition - 1 error:nil];
        NSRange range = NSMakeRange(begin, end - begin);
        
        UIFont *newFont = [UIFont fontFromStyle:span.style forString:label.label];
        NSDictionary *dict = @{
                               (NSString *)kCTFontAttributeName: newFont,
                               NSLigatureAttributeName : @(0) // No ligatures
                               };
        
        [completeAttributedString setAttributes:dict range:range];
    }
    return completeAttributedString;
}

@end

