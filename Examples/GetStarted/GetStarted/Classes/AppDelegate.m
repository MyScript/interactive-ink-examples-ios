// Copyright MyScript. All right reserved.

#import "AppDelegate.h"
#import <iink/IINK.h>
#import "MyCertificate.h"

@interface AppDelegate ()

@property (strong, nonatomic) IINKEngine *engine;
@property (strong, nonatomic) NSString *engineErrorMessage;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

/**
 * Engine "singleton".
 *
 * @return the application engine.
 */

- (IINKEngine *)engine
{
    if (!_engine)
    {
        // Check that the MyScript certificate is present
        if (myCertificate.length == 0)
        {
            self.engineErrorMessage = @"Please replace the content of MyCertificate.c with the certificate you received from the developer portal";
            return nil;
        }

        // Create the iink runtime environment
        NSData* certificateData = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];
        self.engine = [[IINKEngine alloc] initWithCertificate:certificateData];
        if (self.engine == nil)
        {
            self.engineErrorMessage = @"Invalid certificate";
            return nil;
        }

        // Configure the iink runtime environment
        NSString *configurationPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"recognition-assets/conf"];
        [self.engine.configuration setStringArray:@[configurationPath] forKey:@"configuration-manager.search-path" error:nil]; // Tells the engine where to load the recognition assets from.
        
        // Set the temporary directory
        [self.engine.configuration setString:NSTemporaryDirectory() forKey:@"content-package.temp-folder" error:nil];
    }
    return _engine;
}

@end
