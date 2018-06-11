// Copyright MyScript. All right reserved.

#import <IInkUIReferenceImplementation/IInkUIReferenceImplementation.h>
#import "ExportTableViewController.h"

@interface ExportTableViewController ()

@property (strong, nonatomic) NSArray<IINKMimeTypeValue *> *mimeTypes;

@end

@implementation ExportTableViewController

#pragma mark - Setter

- (void)setEditor:(IINKEditor *)editor
{
	_editor = editor;
	self.mimeTypes = [editor getSupportedExportMimeTypes:self.editor.rootBlock];
}

#pragma mark - IBActions

- (IBAction)close:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 0)
    {
        return @"The exported files will be in the document directory";
    }

	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.mimeTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExportCellId" forIndexPath:indexPath];

    NSString *mimeTypeName = [IINKMimeTypeValue IINKMimeTypeGetName:self.mimeTypes[indexPath.row].value];
	cell.textLabel.text = mimeTypeName;

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	IINKMimeTypeValue *mimeTypeNumber = self.mimeTypes[indexPath.row];

    ImageLoader *imageLoader = [[ImageLoader alloc] init];
	imageLoader.cacheFolderPath = [[NSFileManager defaultManager] tmpDirectory];
	imageLoader.editor = self.editor;
    ImageDrawer *imageDrawer = [[ImageDrawer alloc] init];
	imageDrawer.imageLoader = imageLoader;
	NSString *part = self.editor.part.identifier;
	NSString *type = self.editor.part.type;
    NSString *extension = [IINKMimeTypeValue IINKMimeTypeGetFileExtensions:mimeTypeNumber.value];
    extension = [extension componentsSeparatedByString:@","].firstObject;
	NSString *fileName = [NSString stringWithFormat:@"%@-%@%@", part, type, extension];
	NSString *path = [[NSFileManager defaultManager] pathForFileInDocumentDirectory:fileName];

	[self.editor waitForIdle];

    BOOL success = [self.editor export_:self.editor.rootBlock toFile:path mimeType:mimeTypeNumber.value imageDrawer:imageDrawer error:nil];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	UIViewController *presentingViewController = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *title = success ? @"Export succeeded" : @"Export failed";
        NSString *message = [NSString stringWithFormat:(success ? @"The content has been exported to %@ successfuly" : @"Failed to export the content to %@"), fileName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [presentingViewController presentViewController:alertController animated:YES completion:nil];
    }];
}

@end
