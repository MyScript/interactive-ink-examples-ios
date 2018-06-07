// Copyright MyScript. All right reserved.

#import "MainNavigationViewController.h"
#import <iink/IINK.h>
#import "MyCertificate.h"

@interface MainNavigationViewController ()

@property (strong, nonatomic) IINKEngine *engine;
@property (strong, nonatomic) NSString *engineErrorMessage;

@end

@implementation MainNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Check that the MyScript certificate is present
    if (myCertificate.length == 0)
    {
        self.engineErrorMessage = @"Please replace the content of MyCertificate.c with the certificate you received from the developer portal";
        return;
    }

    // Create the iink runtime environment
    NSData *certificateData = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];
    self.engine = [[IINKEngine alloc] initWithCertificate:certificateData];
    if (self.engine == nil)
    {
        self.engineErrorMessage = @"Invalid certificate";
        return;
    }

    // Configure the iink runtime environment
    NSString *configurationPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"recognition-assets/conf"];
    [self.engine.configuration setStringArray:@[ configurationPath ] forKey:@"configuration-manager.search-path" error:nil];
    
    // Set the temporary directory
    [self.engine.configuration setString:NSTemporaryDirectory() forKey:@"content-package.temp-folder" error:nil];
}

@end
