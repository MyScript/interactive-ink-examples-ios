// Copyright MyScript. All right reserved.

#import "AppDelegate.h"
#import <IInkUIReferenceImplementation/NSFileManager+Additions.h>
#import <IInkUIReferenceImplementation/UIfont+Helper.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create iink folder in Documents. Future iink user files will be saved there.
	[[NSFileManager defaultManager] createIinkDirectory];
	NSLog(@"IinkDirectory %@", [[NSFileManager defaultManager] iinkDirectory]);

    // Load custom fonts from bundle. Default ones are used for better Math typeset rendering.
    [UIFont loadCustomFontsFromBundle:[NSBundle mainBundle]];

	return YES;
}

@end
