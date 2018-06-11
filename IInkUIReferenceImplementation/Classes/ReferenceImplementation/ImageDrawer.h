// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>

#import <iink/IINKIImageDrawer.h>
#import <iink/IINKMimeType.h>

@class ImageLoader, IINKRenderer;

@interface ImageDrawer : NSObject <IINKIImageDrawer>

@property (nullable, nonatomic, strong) ImageLoader *imageLoader;
/** The image background color. **/
@property(nullable, nonatomic,copy) UIColor *backgroundColor;

@end
