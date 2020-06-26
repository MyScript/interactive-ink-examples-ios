// Copyright @ MyScript. All rights reserved.

#import "Canvas.h"
#import "Path.h"
#import "UIfont+Helper.h"
#import "ImageLoader.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#import "ImageLoader.h"
#import "OffscreenRenderSurfaces.h"
#import <iink/graphics/IINKStyle.h>
#import "IInkUIRefImplUtils.h"

@interface Canvas ()
{
    void (*fillPath)(CGContextRef c);
}

@property (nonatomic) CGAffineTransform aTransform;
@property (strong, nonatomic) IINKStyle *style;
@property (nonatomic) NSMutableDictionary *fontAttributeDict;
@property (nonatomic, strong) NSString *clippedGroupIdentifier;

@end

@implementation Canvas

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.clearAtStartDraw = YES;
        self.style = [[IINKStyle alloc] init];
        self.aTransform = CGAffineTransformIdentity;
        self.fontAttributeDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Drawing Session Management

- (void)startDrawInRect:(CGRect)rect
{
    if (self.context == nil)
    {
        self.context = UIGraphicsGetCurrentContext();
    }

    (void)[self.style init];
    self.aTransform = CGAffineTransformIdentity;
    [self.fontAttributeDict removeAllObjects];

    CGContextSaveGState(self.context);

    // Enforce defaults
    [self.style setAllChangeFlags];
    [self.style applyTo:self];
    [self.style clearChangeFlags];

    // Specific transform for text since we use CoreText to draw
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -self.size.height);
    CGContextSetTextMatrix(self.context, transform);

    CGContextClipToRect(self.context, rect);
    if (self.clearAtStartDraw)
        CGContextClearRect(self.context, rect);
}

- (void)endDraw
{
    CGContextRestoreGState(self.context);
}

#pragma mark - View Properties

- (CGAffineTransform)getTransform
{
    return self.aTransform;
}

- (void)setTransform:(CGAffineTransform)transform
{
    CGAffineTransform invertedTransform = CGAffineTransformInvert(self.aTransform);
    CGAffineTransform resultTransform = CGAffineTransformConcat(transform, invertedTransform);
    
    _aTransform = transform;

    CGContextConcatCTM(self.context, resultTransform);
}

#pragma mark - Stroking Properties

- (void)setStrokeColor:(uint32_t)color
{
    self.style.strokeColor = color;
    CGContextSetStrokeColorWithColor(self.context, [IInkUIRefImplUtils uiColor:color].CGColor);
}

- (void)setStrokeWidth:(float)width
{
    self.style.strokeWidth = width;
    CGContextSetLineWidth(self.context, width);
}

- (void)setStrokeLineCap:(IINKLineCap)lineCap
{
    self.style.strokeLineCap = lineCap;
    switch (lineCap) {
        case IINKLineCapButt:
            CGContextSetLineCap(self.context, kCGLineCapButt);
            break;
        case IINKLineCapRound:
            CGContextSetLineCap(self.context, kCGLineCapRound);
            break;
        case IINKLineCapSquare:
            CGContextSetLineCap(self.context, kCGLineCapSquare);
            break;
        default:
            break;
    }
}

- (void)setStrokeLineJoin:(IINKLineJoin)lineJoin
{
    self.style.strokeLineJoin = lineJoin;
    switch (lineJoin) {
        case IINKLineJoinMiter:
            CGContextSetLineJoin(self.context, kCGLineJoinMiter);
            break;
        case IINKLineJoinRound:
            CGContextSetLineJoin(self.context, kCGLineJoinRound);
            break;
        case IINKLineJoinBevel:
            CGContextSetLineJoin(self.context, kCGLineJoinBevel);
            break;
        default:
            break;
    }
}

- (void)setStrokeMiterLimit:(float)limit
{
    self.style.strokeMiterLimit = limit;
    CGContextSetMiterLimit(self.context, limit);
}

- (void)setLineDash
{
    if (self.style.strokeDashArray.count > 0)
    {
        CGFloat dashes[self.style.strokeDashArray.count];
        for (NSUInteger i = 0; i < self.style.strokeDashArray.count; i++)
        {
            NSNumber *dash = self.style.strokeDashArray[i];
            dashes[i] = dash.floatValue;
        }
        CGContextSetLineDash(self.context, self.style.strokeDashOffset, dashes, self.style.strokeDashArray.count);
    }
    else
    {
        CGContextSetLineDash(self.context, 0, NULL, 0);
    }
}

- (void)setStrokeDashArray:(const float *)array size:(size_t)size
{
    NSMutableArray *dashes = [NSMutableArray array];
    for (size_t i = 0; i < size; i++) {
        float value = array[i];
        [dashes addObject:@(value)];
    }
    self.style.strokeDashArray = dashes;
    [self setLineDash];
}

- (void)setStrokeDashOffset:(float)offset
{
    self.style.strokeDashOffset = offset;
    [self setLineDash];
}

#pragma mark - Filling Properties

- (void)setFillColor:(uint32_t)color
{
    self.style.fillColor = color;
    CGContextSetFillColorWithColor(self.context, [IInkUIRefImplUtils uiColor:color].CGColor);
    [self.fontAttributeDict setObject:[IInkUIRefImplUtils uiColor:color] forKey:NSForegroundColorAttributeName];
}

- (void)setFillRule:(IINKFillRule)rule
{
    self.style.fillRule = rule;
    self->fillPath = (rule == IINKFillRuleEvenOdd) ? CGContextEOFillPath : CGContextFillPath;
}

#pragma mark - Font Properties

- (void)setFontProperties:(NSString *)family
                   height:(float)lineHeight size:(float)size
                    style:(NSString *)style variant:(NSString *)variant
                   weight:(int)weight
{
    self.style.fontFamily = family;
    self.style.fontLineHeight = lineHeight;
    self.style.fontSize = size;
    self.style.fontStyle = style;
    self.style.fontVariant = variant;
    self.style.fontWeight = weight;
    
    UIFont *font = [UIFont fontFromStyle:self.style];
    [self.fontAttributeDict setObject:font forKey:NSFontAttributeName];

    [self.fontAttributeDict setValue:@(0) forKey:NSLigatureAttributeName];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:self.style.fontLineHeight];
    [self.fontAttributeDict setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
}

#pragma mark - Group Management

- (void)startGroup:(NSString *)identifier region:(CGRect)region clip:(BOOL)clipContent
{
    if (clipContent)
    {
        self.clippedGroupIdentifier = identifier;
        [self.style clearChangeFlags];
        CGContextSaveGState(self.context);
        CGContextClipToRect(self.context, CGRectMake(region.origin.x, region.origin.y, CGRectGetWidth(region), CGRectGetHeight(region)));
    }
}

- (void)endGroup:(NSString *)identifier
{
    if ([identifier isEqualToString:self.clippedGroupIdentifier])
    {
        CGContextRestoreGState(self.context);
        [self.style applyTo:self];
        self.clippedGroupIdentifier = nil;
    }
}

- (void)startItem:(NSString *)identifier
{
    
}

- (void)endItem:(NSString *)identifier
{
    
}

#pragma mark - Drawing Commands

- (nonnull id<IINKIPath>)createPath
{
    return [[Path alloc] init];
}

- (void)drawPath:(id<IINKIPath>)path
{
    Path *aPath = path;

    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.fillColor] > 0.)
    {
        CGContextAddPath(self.context, aPath.bezierPath.CGPath);
        self->fillPath(self.context);
    }
    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.strokeColor] > 0.)
    {
        CGContextAddPath(self.context, aPath.bezierPath.CGPath);
        CGContextStrokePath(self.context);
    }
}

- (void)drawRectangle:(CGRect)rect
{
    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.fillColor] > 0.)
    {
        CGContextFillRect(self.context, rect);
    }
    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.strokeColor] > 0.)
    {
        CGContextStrokeRect(self.context, rect);
    }
}

- (void)drawLine:(CGPoint)from to:(CGPoint)to
{
    CGContextMoveToPoint(self.context, from.x, from.y);
    CGContextAddLineToPoint(self.context, to.x, to.y);
    CGContextStrokePath(self.context);
}

- (void)drawObject:(NSString *)url mimeType:(NSString*)mimeType region:(CGRect)rect
{
    if ([mimeType containsString:@"image"])
    {
        id object = [self.imageLoader imageFromURL:url];

        CGContextSaveGState(self.context);
        
        CGContextTranslateCTM(self.context, 0, 2 * rect.origin.y + CGRectGetHeight(rect));
        CGContextScaleCTM(self.context, 1, -1);
        
        UIImage *image = [UIImage imageWithData:object];
        
        CGRect aRect = CGRectMake(rect.origin.x, rect.origin.y, CGRectGetWidth(rect), CGRectGetHeight(rect));
        CGContextDrawImage(self.context, aRect, image.CGImage);
        CGContextRestoreGState(self.context);
    }
}

- (void)drawText:(NSString *)label anchor:(CGPoint)origin region:(CGRect)rect
{
    [self.fontAttributeDict setObject:[UIFont fontFromStyle:self.style forString:label] forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:label attributes:self.fontAttributeDict];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CGContextSetTextPosition(self.context, origin.x, origin.y);
    CTLineDraw(line, self.context);
    CFRelease(line);
}

- (void)blendOffscreen:(uint32_t)surfaceId src:(CGRect)src dest:(CGRect)dest color:(uint32_t)color
{
    CGLayerRef buffer = [self.offscreenRenderSurfaces getSurfaceBufferForId:surfaceId];
    assert(buffer != nullptr);
    CGSize size = CGLayerGetSize(buffer);
    CGFloat scale = self.offscreenRenderSurfaces.scale;

    CGContextSaveGState(self.context);
    CGContextClipToRect(self.context, dest);

    CGFloat alpha = (color & 0xff) / 255.0f;
    CGContextSetAlpha(self.context, alpha);

    CGRect src_ = CGRectMake(src.origin.x * scale, src.origin.y * scale, src.size.width * scale, src.size.height * scale);

    CGFloat x = dest.origin.x - src_.origin.x / src_.size.width * dest.size.width;
    CGFloat y = dest.origin.y - src_.origin.y / src_.size.height * dest.size.height;
    CGFloat width = size.width / src_.size.width * dest.size.width;
    CGFloat height = size.height / src_.size.height * dest.size.height;
    CGContextDrawLayerInRect(self.context, CGRectMake(x, y, width, height), buffer);

    CGContextRestoreGState(self.context);
}

@end
