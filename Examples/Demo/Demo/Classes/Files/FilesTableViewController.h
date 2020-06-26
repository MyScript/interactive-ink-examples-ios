// Copyright @ MyScript. All rights reserved.

#import <UIKit/UIKit.h>

/**
 * Presents a list of files from the application documents iink folder that can be opened inside the application.
 */
@interface FilesTableViewController : UITableViewController

@property (strong, nonatomic, readonly) NSString *selectedDocPath;

@end
