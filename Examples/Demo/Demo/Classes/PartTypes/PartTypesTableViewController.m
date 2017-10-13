// Copyright MyScript. All right reserved.

#import "PartTypesTableViewController.h"
#import "MainNavigationViewController.h"
#import <IInkUIReferenceImplementation/IInkUIReferenceImplementation.h>

@interface PartTypesTableViewController ()


@property (nonatomic, strong) IBOutlet UIBarButtonItem *createBarButtonItem;

@property (nonatomic, assign) NSUInteger cellIndex;

@end

@implementation PartTypesTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PartTypeCellReuseIdentifier"];

    if (!self.cancelable)
        self.navigationItem.leftBarButtonItem = nil;
    
	self.createBarButtonItem.enabled = NO;
}
    
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.engine.supportedPartTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PartTypeCellReuseIdentifier"];
    NSString *partType = [self.engine.supportedPartTypes objectAtIndex:indexPath.row];
    cell.textLabel.text = partType;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.cellIndex inSection:0];
	UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
	oldCell.accessoryType = UITableViewCellAccessoryNone;

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.cellIndex = indexPath.row;
    _partType = [self.engine.supportedPartTypes objectAtIndex:indexPath.row];

	self.createBarButtonItem.enabled = YES;
}

#pragma mark - IBAction

- (IBAction)close:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Engine

- (IINKEngine *)engine
{
    MainNavigationViewController *rootViewController = (MainNavigationViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    return rootViewController.engine;
}

@end
