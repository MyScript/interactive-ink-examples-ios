// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>
#import <iink/IINKEditor.h>

@interface ImageLoader : NSObject

@property (strong, nonatomic) NSString *cacheFolderPath;

@property (weak, nonatomic) IINKEditor *editor;

- (id)objectForKey:(NSString *)key;

- (id)insertNewObjectForKey:(NSString *)key;

@end
