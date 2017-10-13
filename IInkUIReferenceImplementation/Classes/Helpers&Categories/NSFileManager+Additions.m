// Copyright MyScript. All right reserved.

#import "NSFileManager+Additions.h"

@implementation NSFileManager (Additions)

- (void)createIinkDirectory
{
    NSString *documentDirectory  = [[NSFileManager defaultManager] documentDirectory];
    NSString *iinkFilesDirectory = [documentDirectory stringByAppendingPathComponent:@"iinkFiles"];
    if (![self fileExistsAtPath:iinkFilesDirectory])
    {
        NSError *error;
        [self createDirectoryAtPath:iinkFilesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        if (error)
        {
            NSLog(@"Can't create dir %@, error %@", iinkFilesDirectory, error.localizedDescription);
        }
    }
}

- (NSString *)cachesDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *cachesDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return cachesDirectory;
}

- (NSString *)tmpDirectory
{
    return NSTemporaryDirectory();
}

- (NSString *)pathForFileInCachesDirectory:(NSString *)fileName
{
    NSString *cachesDirectory = [[NSFileManager defaultManager] cachesDirectory];
    NSString *fullPath        = [NSString stringWithFormat:@"%@/%@", cachesDirectory, fileName];

    return fullPath;
}

- (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return documentDirectory;
}

- (NSString *)iinkDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return [documentDirectory stringByAppendingPathComponent:@"iinkFiles"];
}

- (NSString *)documentInboxDirectory
{
    return [[self documentDirectory] stringByAppendingPathComponent:@"Inbox"];
}

- (NSString *)libraryDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *libraryDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return libraryDirectory;
}

- (NSString *)pathForFileInDocumentDirectory:(NSString *)fileName
{
    NSString *documentDirectory = [[NSFileManager defaultManager] documentDirectory];
    NSString *fullPath          = [NSString stringWithFormat:@"%@/%@", documentDirectory, fileName];
    
    return fullPath;
}

- (NSString *)pathForFileInIinkDirectory:(NSString *)fileName
{
    NSString *documentDirectory  = [[NSFileManager defaultManager] documentDirectory];
    NSString *iinkFilesDirectory = [documentDirectory stringByAppendingPathComponent:@"iinkFiles"];
    NSString *fullPath           = [NSString stringWithFormat:@"%@/%@", iinkFilesDirectory, fileName];
    
    return fullPath;
}

- (NSString *)pathForFileInLibraryDirectory:(NSString *)fileName
{
    NSString *libraryDirectory = [[NSFileManager defaultManager] libraryDirectory];
    NSString *fullPath         = [NSString stringWithFormat:@"%@/%@", libraryDirectory, fileName];
    
    return fullPath;
}

- (NSString *)pathForFileInTmpDirectory:(NSString *)fileName
{
    NSString *tmpDirectory     = [[NSFileManager defaultManager] tmpDirectory];
    NSString *fullPath         = [NSString stringWithFormat:@"%@%@", tmpDirectory, fileName];
    
    return fullPath;
}

@end
