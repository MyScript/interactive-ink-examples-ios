// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>

#import <iink/IINKIImageDrawer.h>

@class ImageLoader, IINKRenderer;

@interface ImageDrawer : NSObject <IINKIImageDrawer>

@property (nonatomic, strong) ImageLoader *imageLoader;

@end
