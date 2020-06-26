// Copyright @ MyScript. All rights reserved.

#import <UIKit/UIKit.h>
#import <iink/IINKIRenderTarget.h>

@class IINKRenderer, ImageLoader, OffscreenRenderSurfaces;

@interface RenderView : UIView

@property (nonatomic) IINKLayerType layerType;

@property (weak, nonatomic) IINKRenderer *renderer;

@property (weak, nonatomic) ImageLoader *imageLoader;

@property (weak, nonatomic) OffscreenRenderSurfaces *offscreenRenderSurfaces;

@end
