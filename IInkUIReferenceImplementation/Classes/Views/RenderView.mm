// Copyright @ MyScript. All rights reserved.

#import "RenderView.h"
#import "Canvas.h"
#import "OffscreenRenderSurfaces.h"
#import <iink/IINKRenderer.h>

@interface RenderView()

@property (strong, nonatomic) Canvas *canvas;

@end

@implementation RenderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self ownInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self ownInit];
    }
    return self;
}

- (void)ownInit
{
    self.layer.drawsAsynchronously = YES;
    self.canvas = [[Canvas alloc] init];
}

- (void)setImageLoader:(ImageLoader *)imageLoader
{
    _imageLoader = imageLoader;
    self.canvas.imageLoader = imageLoader;
}

- (void)setOffscreenRenderSurfaces:(OffscreenRenderSurfaces *)offscreenRenderSurfaces
{
    _offscreenRenderSurfaces = offscreenRenderSurfaces;
    self.canvas.offscreenRenderSurfaces = offscreenRenderSurfaces;
}

- (void)layerWillDraw:(CALayer *)layer
{
    if (@available(iOS 10, *))
    {
        // 8-bit sRGB (probably fine unless there’s wide color content)
        self.layer.contentsFormat = kCAContentsFormatRGBA8Uint;
    }
}

- (void)drawRect:(CGRect)rect
{
    self.canvas.context = UIGraphicsGetCurrentContext();
    self.canvas.size = self.bounds.size;
    self.canvas.clearAtStartDraw = NO;

    switch (self.layerType)
    {
        case IINKLayerTypeBackground:
            break;
        case IINKLayerTypeModel:
            [self.renderer drawModel:rect canvas:self.canvas];
            break;
        case IINKLayerTypeTemporary:
            break;
        case IINKLayerTypeCapture:
            [self.renderer drawCaptureStrokes:rect canvas:self.canvas];
            break;
    }
}

@end
