// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>

@class IINKText;
@class IINKTextSpan;

@interface NSAttributedString (Helper)

- (NSArray<NSValue *> *)charactersBoundingBoxes; // NSArray of CGRect NSValues

- (NSArray<NSValue *> *)glyphMetrics; // NSArray of IINKGlyphMetrics NSValues

+ (NSAttributedString *)attributedStringWithText:(IINKText *)label
                                          spans:(NSArray<IINKTextSpan *> *)spans;

@end
