// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IInkUIRefImplUtils : NSObject

+ (CGFloat)redComponentFromColor:(uint32_t)colorInt32;
+ (CGFloat)greenComponentFromColor:(uint32_t)colorInt32;
+ (CGFloat)blueComponentFromColor:(uint32_t)colorInt32;
+ (CGFloat)alphaComponentFromColor:(uint32_t)colorInt32;
+ (UIColor *)uiColor:(uint32_t)rgba;

@end
