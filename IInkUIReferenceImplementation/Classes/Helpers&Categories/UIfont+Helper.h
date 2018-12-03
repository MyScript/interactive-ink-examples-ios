// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>

@class IINKStyle;

@interface UIFont (Helper)

+ (void)loadCustomFontsFromBundle:(NSBundle *)bundle;

+ (UIFont *)fontFromStyle:(IINKStyle *)style forString:(NSString*)string;
+ (UIFont *)fontFromStyle:(IINKStyle *)style;

@end
