// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>

@class IINKEngine;

/**
 * Navigation controller used to keep alive an instance of the iink engine.
 */
@interface MainNavigationViewController : UINavigationController

@property (strong, nonatomic, readonly) IINKEngine *engine;
@property (strong, nonatomic, readonly) NSString *engineErrorMessage;

@end
