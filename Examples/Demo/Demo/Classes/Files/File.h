// Copyright @ MyScript. All rights reserved.

#import <Foundation/Foundation.h>

@interface File : NSObject

@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSDate *mofificationDate;
@property (nonatomic) float fileSize;

@end
