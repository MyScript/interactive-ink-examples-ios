// Copyright MyScript. All right reserved.

@import UIKit;

@class IINKEngine;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) IINKEngine *engine;
@property (strong, nonatomic, readonly) NSString *engineErrorMessage;

@end

