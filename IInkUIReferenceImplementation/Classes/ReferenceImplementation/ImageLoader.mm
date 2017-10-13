// Copyright MyScript. All right reserved.

#import "ImageLoader.h"

#import <iink/IINKContentPart.h>
#import <iink/IINKContentPackage.h>

@interface ImageLoader ()

@property (strong, nonatomic) NSMutableDictionary *dictionary;

@end

@implementation ImageLoader

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    return self.dictionary[key];
}

- (id)insertNewObjectForKey:(NSString *)key
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%f.png", timeInterval];
    NSString *filePath = [_cacheFolderPath stringByAppendingPathComponent:fileName];
    [self.editor.part.package extractObject:key toFile:filePath.decomposedStringWithCanonicalMapping error:nil];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data)
    {
        self.dictionary[key] = data;
    }
    
    return data;
}

@end
