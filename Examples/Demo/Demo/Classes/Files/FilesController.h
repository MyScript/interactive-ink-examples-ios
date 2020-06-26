// Copyright @ MyScript. All rights reserved.

#import <Foundation/Foundation.h>

@class File;

@interface FilesController : NSObject

+ (instancetype)sharedController;

- (NSArray<File *> *)iinkFilesFromIInkDirectory;

@end
