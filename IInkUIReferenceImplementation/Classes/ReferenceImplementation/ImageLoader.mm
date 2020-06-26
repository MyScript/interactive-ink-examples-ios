// Copyright @ MyScript. All rights reserved.

#import "ImageLoader.h"

#import <iink/IINKContentPart.h>
#import <iink/IINKContentPackage.h>

#define CACHE_MAX_BYTES (200*1000000) // 200M (in Bytes)

@interface ImageLoader ()

@property (strong, nonatomic) NSCache *cache;

@end

@implementation ImageLoader

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.cache = [[NSCache alloc] init];
        self.cache.name = [[NSString alloc] initWithFormat:@"Image Loader (%p)", self];
        self.cache.totalCostLimit = CACHE_MAX_BYTES;
    }
    return self;
}


- (id)imageFromURL:(NSString *)url
{
    NSData* obj = nil;
    @synchronized(self) {
        obj = [self.cache objectForKey:url];
        if (obj == nil)
        {
            obj = [NSData dataWithContentsOfFile:url];
            [self.cache setObject:obj forKey:url cost:obj.length];
        }
    }
    return obj;
}

@end
