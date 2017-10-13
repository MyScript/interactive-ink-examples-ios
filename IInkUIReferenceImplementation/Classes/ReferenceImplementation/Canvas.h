// Copyright MyScript. All right reserved.

#import <iink/graphics/IINKICanvas.h>
#import <UIKit/UIKit.h>

@class ImageLoader, IINKStyle;

@interface Canvas : NSObject <IINKICanvas>

@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) ImageLoader *imageLoader;
@property (strong, nonatomic) IINKStyle *style;

- (void)reset;

@end
