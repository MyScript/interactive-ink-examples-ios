// Copyright MyScript. All right reserved.

#import "Canvas.h"
#import "Path.h"
#import "UIfont+Helper.h"
#import "ImageLoader.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#import "ImageLoader.h"
#import <iink/graphics/IINKStyle.h>
#import "IInkUIRefImplUtils.h"

@interface Canvas ()
{
    void (*fillPath)(CGContextRef c);
}

@property (nonatomic) CGAffineTransform aTransform;
@property (nonatomic) NSDictionary *fontAttributeDict;

@end

@implementation Canvas

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self ownInit];
    }
    return self;
}

- (void)ownInit
{
    self.style = [[IINKStyle alloc] init];
    self.aTransform = CGAffineTransformIdentity;

    if (UIGraphicsGetCurrentContext())
    {
        // Enforce defaults
        [self.style setAllChangeFlags];
        [self.style applyTo:self];
        [self.style clearChangeFlags];
    }
}

- (CGAffineTransform)getTransform
{
    return self.aTransform;
}

- (void)setTransform:(CGAffineTransform)transform
{
    CGAffineTransform invertedTransform = CGAffineTransformInvert(self.aTransform);
    CGAffineTransform resultTransform = CGAffineTransformConcat(transform, invertedTransform);
    
    _aTransform = transform;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, resultTransform);
}

#pragma mark - Stroking Properties

- (void)setStrokeColor:(uint32_t)color
{
    self.style.strokeColor = color;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [IInkUIRefImplUtils uiColor:color].CGColor);
}

- (void)setStrokeWidth:(float)width
{
    self.style.strokeWidth = width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width);
}

- (void)setStrokeLineCap:(IINKLineCap)lineCap
{
    self.style.strokeLineCap = lineCap;
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (lineCap) {
        case IINKLineCapButt:
            CGContextSetLineCap(context, kCGLineCapButt);
            break;
        case IINKLineCapRound:
            CGContextSetLineCap(context, kCGLineCapRound);
            break;
        case IINKLineCapSquare:
            CGContextSetLineCap(context, kCGLineCapSquare);
            break;
        default:
            break;
    }
}

- (void)setStrokeLineJoin:(IINKLineJoin)lineJoin
{
    self.style.strokeLineJoin = lineJoin;
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (lineJoin) {
        case IINKLineJoinMiter:
            CGContextSetLineJoin(context, kCGLineJoinMiter);
            break;
        case IINKLineJoinRound:
            CGContextSetLineJoin(context, kCGLineJoinRound);
            break;
        case IINKLineJoinBevel:
            CGContextSetLineJoin(context, kCGLineJoinBevel);
            break;
        default:
            break;
    }
}

- (void)setStrokeMiterLimit:(float)limit
{
    self.style.strokeMiterLimit = limit;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetMiterLimit(context, limit);
}

- (void)setLineDash
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (self.style.strokeDashArray.count > 0)
    {
        CGFloat dashes[self.style.strokeDashArray.count];
        for (NSUInteger i = 0; i < self.style.strokeDashArray.count; i++)
        {
            NSNumber *dash = self.style.strokeDashArray[i];
            dashes[i] = dash.floatValue;
        }
        CGContextSetLineDash(context, self.style.strokeDashOffset, dashes, self.style.strokeDashArray.count);
    }
    else
    {
        CGContextSetLineDash(context, 0, NULL, 0);
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [IInkUIRefImplUtils uiColor:color].CGColor);
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
    
    self.font = [UIFont fontFromStyle:self.style];
    NSMutableParagraphStyle *s = [[NSMutableParagraphStyle alloc] init];
    [s setLineSpacing:self.style.fontLineHeight];
    self.fontAttributeDict = @{
                               NSFontAttributeName : self.font,
                               NSLigatureAttributeName         : @(0), // No ligatures
                               NSParagraphStyleAttributeName   : s,
                               NSForegroundColorAttributeName  : [IInkUIRefImplUtils uiColor:self.style.fillColor]
                               };
}

#pragma mark - Group Management

- (void)startGroup:(NSString *)identifier region:(CGRect)region clip:(BOOL)clipContent
{
    [self.style clearChangeFlags];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    if (clipContent)
    {
        CGContextClipToRect(context, CGRectMake(region.origin.x, region.origin.y, CGRectGetWidth(region), CGRectGetHeight(region)));
    }
}

- (void)endGroup:(NSString *)identifier
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRestoreGState(context);
    [self.style applyTo:self];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    Path *aPath = path;

    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.fillColor] > 0.)
    {
        CGContextAddPath(context, aPath.bezierPath.CGPath);
        self->fillPath(context);
    }
    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.strokeColor] > 0.)
    {
        CGContextAddPath(context, aPath.bezierPath.CGPath);
        CGContextStrokePath(context);
    }
}

- (void)drawRectangle:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.fillColor] > 0.)
    {
        CGContextFillRect(context, rect);
    }
    if ([IInkUIRefImplUtils alphaComponentFromColor:self.style.strokeColor] > 0.)
    {
        CGContextStrokeRect(context, rect);
    }
}

- (void)drawLine:(CGPoint)from to:(CGPoint)to
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
}

- (void)drawObject:(NSString *)url mimeType:(NSString*)mimeType region:(CGRect)rect
{
    if ([mimeType containsString:@"image"])
    {
        id object = [self.imageLoader objectForKey:url];
        if (!object)
        {
            object = [self.imageLoader insertNewObjectForKey:url];
        }
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, 0, 2 * rect.origin.y + CGRectGetHeight(rect));
        CGContextScaleCTM(context, 1, -1);
        
        UIImage *image = [UIImage imageWithData:object];
        
        CGRect aRect = CGRectMake(rect.origin.x, rect.origin.y, CGRectGetWidth(rect), CGRectGetHeight(rect));
        CGContextDrawImage(context, aRect, image.CGImage);
        CGContextRestoreGState(context);
    }
}

- (void)drawText:(NSString *)label anchor:(CGPoint)origin region:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:label attributes:self.fontAttributeDict];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CGContextSetTextPosition(context, origin.x, origin.y);
    CTLineDraw(line, context);
    CFRelease(line);
}

- (void)reset
{
    [self ownInit];
}

@end
