// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import <iink/IINKIRenderTarget.h>

@class IINKEditor, ImageLoader;

@interface DisplayViewController : UIViewController <IINKIRenderTarget>

@property (weak, nonatomic) IINKRenderer *renderer;
//- (IINKRenderer *)renderer UNAVAILABLE_ATTRIBUTE;

@property (strong, nonatomic) ImageLoader *imageLoader;
//- (ImageLoader *)imageLoader UNAVAILABLE_ATTRIBUTE;

- (void)refreshViews;

@end
