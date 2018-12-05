// Copyright MyScript. All right reserved.

#import "RenderView.h"
#import "Canvas.h"
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.canvas reset];
    
    // Specific transform for text since we use CoreText to draw
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -self.bounds.size.height);
  
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, transform);

    switch (self.layerType)
    {
        case IINKLayerTypeBackground:
            [self.renderer drawBackground:rect canvas:self.canvas];
            break;
        case IINKLayerTypeModel:
            [self.renderer drawModel:rect canvas:self.canvas];
            break;
        case IINKLayerTypeTemporary:
            [self.renderer drawTemporaryItems:rect canvas:self.canvas];
            break;
        case IINKLayerTypeCapture:
            [self.renderer drawCaptureStrokes:rect canvas:self.canvas];
            break;
    }

    CGContextRestoreGState(context);
}

@end
