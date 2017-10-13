// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import <iink/IINKIRenderTarget.h>

@class ImageLoader, IINKRenderer;

@interface RenderView : UIView

@property (nonatomic) IINKLayerType layerType;

@property (weak, nonatomic) IINKRenderer *renderer;

@property (weak, nonatomic) ImageLoader *imageLoader;

@end
