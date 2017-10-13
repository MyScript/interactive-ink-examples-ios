// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>

@class IINKEditor;

/**
 * Presents a list of files (.doc, .json, ...) in which the current package can be exported to.
 */
@interface ExportTableViewController : UITableViewController

@property (strong, nonatomic) IINKEditor *editor;

@end
