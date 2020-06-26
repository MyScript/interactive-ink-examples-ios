// Copyright @ MyScript. All rights reserved.

#import "FilesTableViewController.h"
#import "FilesController.h"
#import "File.h"
#import <IInkUIReferenceImplementation/NSFileManager+Additions.h>

@interface FilesTableViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *openItem;

@property (strong, nonatomic) NSMutableArray<File *> *docFilenames;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) NSString *selectedDocPath;

@end

@implementation FilesTableViewController

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.docFilenames = [NSMutableArray array];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.openItem.enabled = NO;
    [self.docFilenames addObjectsFromArray:[[FilesController sharedController] iinkFilesFromIInkDirectory]];
}

#pragma mark - IBAction

- (IBAction)close:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.docFilenames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"docFileCellIdentifier" forIndexPath:indexPath];

	File *file = self.docFilenames[indexPath.row];
	cell.textLabel.text = file.filename;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];

	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %.3f Mb", [formatter stringFromDate:file.mofificationDate], file.fileSize / 1000000.f];

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
	UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
	oldCell.accessoryType = UITableViewCellAccessoryNone;

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	self.selectedIndex = indexPath.row;

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;

	File *file = self.docFilenames[indexPath.row];
	self.selectedDocPath = [[NSFileManager defaultManager] pathForFileInIinkDirectory:file.filename];

	self.openItem.enabled = YES;
}

@end
