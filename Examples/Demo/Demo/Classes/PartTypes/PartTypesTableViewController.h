// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>

/**
 * Presents to the user the possible part types (Text Document, Document, Math, Diagram, Drawing).
 */
@interface PartTypesTableViewController : UITableViewController

@property (nonatomic, assign) BOOL onNewPackage;
@property (nonatomic, assign) BOOL cancelable;
@property (nonatomic, strong, readonly) NSString *partType;

@end
