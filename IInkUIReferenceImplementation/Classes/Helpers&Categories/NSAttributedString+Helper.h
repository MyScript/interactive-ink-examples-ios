// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>

@class IINKText;
@class IINKTextSpan;

@interface NSAttributedString (Helper)

+ (NSAttributedString *)attributedStringWithText:(IINKText *)label
                                          spans:(NSArray<IINKTextSpan *> *)spans;

@end
