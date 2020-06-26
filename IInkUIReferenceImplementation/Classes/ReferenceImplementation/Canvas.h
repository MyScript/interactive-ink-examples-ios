// Copyright @ MyScript. All rights reserved.

#import <iink/graphics/IINKICanvas.h>
#import <UIKit/UIKit.h>

@class ImageLoader, OffscreenRenderSurfaces;

@interface Canvas : NSObject <IINKICanvas>

@property (nonatomic) CGContextRef context;
@property (nonatomic) CGSize size;
@property (nonatomic) BOOL clearAtStartDraw;

@property (weak, nonatomic) ImageLoader *imageLoader;
@property (weak, nonatomic) OffscreenRenderSurfaces *offscreenRenderSurfaces;

@end
