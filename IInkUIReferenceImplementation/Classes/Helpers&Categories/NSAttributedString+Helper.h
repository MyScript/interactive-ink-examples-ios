// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>

@class IINKText;
@class IINKTextSpan;

@interface NSAttributedString (Helper)

- (NSArray<NSValue *> *)charactersBoundingBoxers; // NSArray of CGRect NSValues

+ (NSAttributedString *)attributedStringWithText:(IINKText *)label
                                          spans:(NSArray<IINKTextSpan *> *)spans;

@end
