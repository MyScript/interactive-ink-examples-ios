// Copyright @ MyScript. All rights reserved.

#import <UIKit/UIKit.h>

@interface OffscreenRenderSurfaces : NSObject

@property (nonatomic) CGFloat scale;

- (uint32_t)addSurfaceWithBuffer:(CGLayerRef)buffer;

- (CGLayerRef)getSurfaceBufferForId:(uint32_t)surfaceId;

- (void)releaseSurfaceForId:(uint32_t)surfaceId;

@end
