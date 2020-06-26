// Copyright @ MyScript. All rights reserved.

#import "FilesController.h"
#import "File.h"
#import <IInkUIReferenceImplementation/NSFileManager+Additions.h>

@implementation FilesController

+ (instancetype)sharedController
{
    static FilesController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FilesController alloc] init];
    });
    return sharedInstance;
}

- (NSArray<File *> *)iinkFilesFromIInkDirectory
{
    NSMutableArray<File *> *results = [[NSMutableArray alloc] init];
    // Get the files in itunes folder
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentDirectory = [fileManager iinkDirectory];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentDirectory error:&error];
    if (!error)
    {
        for (NSString *filename in files)
        {
            if ([filename.pathExtension isEqualToString:@"iink"])
            {
                File *file = [[File alloc] init];
                file.filename = filename;
                NSDictionary<NSFileAttributeKey, id> *attributes = [fileManager attributesOfItemAtPath:[documentDirectory stringByAppendingPathComponent:filename] error:nil];
                if (attributes)
                {
                    file.mofificationDate = attributes[NSFileModificationDate];
                    file.fileSize = [attributes[NSFileSize] floatValue];
                }
                [results addObject:file];
            }
        }
    }
    else
    {
        NSLog(@"Error while retrieving files: %@", error.localizedDescription);
    }

    error = nil;
    NSArray * tempFiles = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:&error];
    if (!error)
    {
        for (NSString *filename in tempFiles)
        {
            if ([filename.pathExtension isEqualToString:@"iink-files"])
            {
                File *file = [[File alloc] init];
                file.filename = filename;
                NSDictionary<NSFileAttributeKey, id> *attributes = [fileManager attributesOfItemAtPath:[documentDirectory stringByAppendingPathComponent:filename] error:nil];
                if (attributes)
                {
                    file.mofificationDate = attributes[NSFileModificationDate];
                    file.fileSize = [attributes[NSFileSize] floatValue];
                }
                [results addObject:file];
            }
        }
    }
    else
    {
        NSLog(@"Error while retrieving temporary files: %@", error.localizedDescription);
    }

    return [NSArray arrayWithArray:results];
}

@end
