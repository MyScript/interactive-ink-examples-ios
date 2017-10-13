// Copyright MyScript. All right reserved.

#import "IInkUIRefImplUtils.h"

@implementation IInkUIRefImplUtils

+ (CGFloat)redComponentFromColor:(uint32_t)colorInt32
{
    return ((colorInt32 >> 24) & 0xff) / 255.0f;
}

+ (CGFloat)greenComponentFromColor:(uint32_t)colorInt32
{
    return ((colorInt32 >> 16) & 0xff) / 255.0f;
}

+ (CGFloat)blueComponentFromColor:(uint32_t)colorInt32
{
    return ((colorInt32 >> 8) & 0xff) / 255.0f;
}

+ (CGFloat)alphaComponentFromColor:(uint32_t)colorInt32
{
    return (colorInt32 & 0xff) / 255.0f;
}

+ (UIColor *)uiColor:(uint32_t)rgba
{
    return [UIColor colorWithRed:((rgba >> 24) & 0xff) / 255.0f
                           green:((rgba >> 16) & 0xff) / 255.0f
                            blue:((rgba >> 8) & 0xff) / 255.0f
                           alpha:(rgba & 0xff) / 255.0f];
}

@end
