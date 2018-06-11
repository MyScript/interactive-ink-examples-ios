// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "ImageDrawer.h"
#import "ImageLoader.h"
#import "Canvas.h"

#import <iink/IINKRenderer.h>

@interface ImageDrawer ()

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) IINKMimeType type;

@end

@implementation ImageDrawer

- (void)prepareImage:(CGSize)size
{
    self.imageSize = size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
}

- (void)saveImage:(nonnull NSString *)path
{
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSString* ext = [path pathExtension];
    IINKMimeType mime = (IINKMimeType)-1;
    if ([ext isEqualToString:@"jpeg"])
        mime = IINKMimeTypeJPEG;
    else if ([ext isEqualToString:@"jpg"])
        mime = IINKMimeTypeJPEG;
    else if ([ext isEqualToString:@"jpe"])
        mime = IINKMimeTypeJPEG;
    else if ([ext isEqualToString:@"png"])
        mime = IINKMimeTypePNG;

    NSData* imageData = nil;

    switch (mime)
    {
        case IINKMimeTypeJPEG:
            imageData = UIImageJPEGRepresentation(image, 1);
            break;
        case IINKMimeTypePNG:
            imageData = UIImagePNGRepresentation(image);
            break;
        default:
            break;
    }

    [imageData writeToFile:path atomically:YES];
}

#pragma mark -  IINKIRenderTarget

- (void)invalidate:(nonnull IINKRenderer *)renderer layers:(IINKLayerType)layers
{
    [self invalidate:renderer area:CGRectMake(0, 0, self.imageSize.width, self.imageSize.height) layers:layers];
}

- (void)invalidate:(nonnull IINKRenderer *)renderer area:(CGRect)area layers:(IINKLayerType)layers
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context)
        return;
    
    Canvas *canvas = [[Canvas alloc] init];
    canvas.imageLoader = self.imageLoader;
    
    // Specific transform for text since we use CoreText to draw
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, - self.imageSize.height);

    if (self.backgroundColor)
    {
        CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
        CGContextFillRect(context, (CGRect){CGPointZero, self.imageSize});
    }
    if (layers & IINKLayerTypeCapture)
    {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, transform);
        [renderer drawCaptureStrokes:area canvas:canvas];
        CGContextRestoreGState(context);
    }
    if (layers & IINKLayerTypeTemporary)
    {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, transform);
        [renderer drawTemporaryItems:area canvas:canvas];
        CGContextRestoreGState(context);
    }
    if (layers & IINKLayerTypeModel)
    {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, transform);
        [renderer drawModel:area canvas:canvas];
        CGContextRestoreGState(context);
    }
}

@end
