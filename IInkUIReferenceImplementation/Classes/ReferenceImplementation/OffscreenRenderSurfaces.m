// Copyright @ MyScript. All rights reserved.

#import "OffscreenRenderSurfaces.h"

@interface OffscreenRenderSurface : NSObject

@property (nonatomic) CGLayerRef buffer;

@end

@implementation OffscreenRenderSurface

@end


@interface OffscreenRenderSurfaces ()

@property (nonatomic) NSMutableDictionary *buffers;
@property (nonatomic) uint32_t nextId;

@end

@implementation OffscreenRenderSurfaces

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.buffers = [[NSMutableDictionary alloc] init];
        self.nextId = 0;
    }
    return self;
}

- (void)dealloc
{
    [self.buffers enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        OffscreenRenderSurface *surface = obj;
        CGLayerRelease(surface.buffer);
    }];
}

- (uint32_t)addSurfaceWithBuffer:(CGLayerRef)buffer
{
    OffscreenRenderSurface *surface = [[OffscreenRenderSurface alloc] init];
    surface.buffer = buffer;
    @synchronized (self) {
        uint32_t offscreenId = self.nextId++;
        NSNumber *key = [NSNumber numberWithUnsignedInteger:offscreenId];
        [self.buffers setObject:surface forKey:key];
        return offscreenId;
    }
}

- (CGLayerRef)getSurfaceBufferForId:(uint32_t)offscreenId
{
    NSNumber *key = [NSNumber numberWithUnsignedInteger:offscreenId];
    OffscreenRenderSurface *surface = nil;
    @synchronized (self) {
        surface = [self.buffers objectForKey:key];
    }
    return surface ? surface.buffer : nil;
}

- (void)releaseSurfaceForId:(uint32_t)offscreenId
{
    NSNumber *key = [NSNumber numberWithUnsignedInteger:offscreenId];
    OffscreenRenderSurface *surface = nil;
    @synchronized (self) {
        surface = [self.buffers objectForKey:key];
        [self.buffers removeObjectForKey:key];
    }
    if (surface)
    {
        CGLayerRelease(surface.buffer);
    }
}

@end
