// Copyright MyScript. All right reserved.

#import <Foundation/Foundation.h>

@interface NSFileManager (Additions)

- (void)createIinkDirectory;

- (NSString *)cachesDirectory;

- (NSString *)tmpDirectory;

- (NSString *)pathForFileInCachesDirectory:(NSString *)fileName;

- (NSString *)documentDirectory;

- (NSString *)iinkDirectory;

- (NSString *)documentInboxDirectory;

- (NSString *)libraryDirectory;

- (NSString *)pathForFileInDocumentDirectory:(NSString *)fileName;

- (NSString *)pathForFileInIinkDirectory:(NSString *)fileName;

- (NSString *)pathForFileInLibraryDirectory:(NSString *)fileName;

- (NSString *)pathForFileInTmpDirectory:(NSString *)fileName;

@end
