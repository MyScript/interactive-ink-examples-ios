// Copyright MyScript. All right reserved.

#import "MainViewController.h"
#import "ExportTableViewController.h"
#import "FilesTableViewController.h"
#import "MainNavigationViewController.h"
#import "PartTypesTableViewController.h"
#import <IInkUIReferenceImplementation/IInkUIReferenceImplementation.h>
#import "FilesController.h"
#import "File.h"

@interface MainViewController () <SmartGuideViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousPartItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPartItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPartItem;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *convertItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moreItem;

@property (weak, nonatomic) IBOutlet UISegmentedControl *inputTypeSegmentedControl;

@property (weak, nonatomic) EditorViewController *editorViewController;

@property (assign, nonatomic) CGPoint originalViewOffset;
@property (assign, nonatomic) float originalScale;

@property (strong, nonatomic) IINKContentPackage *currentPackage;
@property (copy, nonatomic) NSString *currentFilename;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation MainViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];

    if (![self checkEngine])
        return;

	self.editorViewController = self.childViewControllers[0];
    self.editorViewController.engine = [self engine];
    self.editorViewController.smartGuideViewController.delegate = self;

    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
    [self.editorViewController.view addGestureRecognizer:self.longPressGestureRecognizer];
    [self configureGestureRecognizer];

	self.versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"NewPartSegueId" sender:self];
    });
}

#pragma mark - Buttons actions

- (IBAction)moreButtonTapped:(id)sender
{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"More actions"
	                                                                         message:nil
	                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Editor actions
    
    UIAlertAction *exportAction = [UIAlertAction actionWithTitle:@"Export" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"ExportSegueId" sender:self];
    }];
    [alertController addAction:exportAction];

    // View actions
    
    UIAlertAction *zoomInAction = [UIAlertAction actionWithTitle:@"Zoom in" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.editorViewController.editor.renderer zoom:(110.0f/100.0f) error:nil];
        [self.editorViewController.displayViewController refreshViews];
    }];
    [alertController addAction:zoomInAction];
    
    UIAlertAction *zoomOutAction = [UIAlertAction actionWithTitle:@"Zoom out" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.editorViewController.editor.renderer zoom:(100.0f/110.0f) error:nil];
        [self.editorViewController.displayViewController refreshViews];
    }];
    [alertController addAction:zoomOutAction];
    
    UIAlertAction *resetViewAction = [UIAlertAction actionWithTitle:@"Reset view" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.editorViewController.editor.renderer setViewScale:1];
        [self.editorViewController.editor.renderer setViewOffset:CGPointMake(0, 0)];
        [self.editorViewController.displayViewController refreshViews];
    }];
    [alertController addAction:resetViewAction];
    
    // File actions
    
    UIAlertAction *newAction = [UIAlertAction actionWithTitle:@"New" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"NewPartSegueId" sender:self];
    }];
    [alertController addAction:newAction];

    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"OpenDocumentSegueId" sender:self];
    }];
	[alertController addAction:openAction];

    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.currentPackage saveWithError:nil];
    }];
    [alertController addAction:saveAction];

	UIPopoverPresentationController *popover = [alertController popoverPresentationController];
	if (popover)
	{
		[popover setPermittedArrowDirections:UIPopoverArrowDirectionUp];
		[popover setBarButtonItem:(UIBarButtonItem *)sender];
		[self presentViewController:alertController animated:YES completion:nil];
	}
	else
	{
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
		[alertController addAction:cancelAction];
		[self presentViewController:alertController animated:YES completion:nil];
	}
}

#pragma mark - Editor related actions

- (IBAction)undo:(id)sender
{
    [self.editorViewController.editor undo];
}

- (IBAction)redo:(id)sender
{
	[self.editorViewController.editor redo];
}

- (IBAction)clear:(id)sender
{
	[self.editorViewController.editor clear];
}

- (IBAction)convert:(id)sender
{
    NSArray<IINKConversionStateValue *> *supportedTargetStates = [self.editorViewController.editor getSupportedTargetConversionState:nil];
    if (supportedTargetStates.count > 0)
        [self.editorViewController.editor convert:nil
                                      targetState:supportedTargetStates[0].value
                                            error:nil];
}

#pragma mark - Parts and packages actions and segues

- (IBAction)previousPart:(id)sender
{
	NSInteger index = [self.currentPackage indexOfPart:self.editorViewController.editor.part];
	if (index > 0)
	{
		[self loadPart:[self.currentPackage getPartAt:--index error:nil]];
	}
}

- (IBAction)nextPart:(id)sender
{
	NSInteger index = [self.currentPackage indexOfPart:self.editorViewController.editor.part];
	NSInteger partCount = self.currentPackage.partCount;
	if (index < partCount - 1)
	{
		[self loadPart:[self.currentPackage getPartAt:++index error:nil]];
	}
}

- (IBAction)createNewPartUnwindSegue:(UIStoryboardSegue *)sender
{
	PartTypesTableViewController *partTypesTableViewController = (PartTypesTableViewController *)sender.sourceViewController;
	NSString *partType = partTypesTableViewController.partType;

    // Create a new pacakage if requested
    if (partTypesTableViewController.onNewPackage)
    {
        [self unloadPart];
        [self createPackage];
    }
    
    // Create a new part to the package
	IINKContentPart *part = [self.currentPackage createPart:partType error:nil];
    // Load it
	[self loadPart:part];
}

- (IBAction)openDocumentUnwindSegue:(UIStoryboardSegue *)sender
{
    IINKEngine *engine = [self engine];

    FilesTableViewController *filesTableViewController = (FilesTableViewController *)sender.sourceViewController;
    NSString *filepath = filesTableViewController.selectedDocPath;

    [self unloadPart];

    // Open it
    self.currentFilename = filepath.lastPathComponent;
    self.addPartItem.enabled = YES;
    self.currentPackage = [engine openPackage:filepath.decomposedStringWithCanonicalMapping error:nil];

    [self loadPart:[self.currentPackage getPartAt:0 error:nil]];
    self.previousPartItem.enabled = NO;
}

#pragma mark - Input type action

- (IBAction)switchValueChanged:(UISegmentedControl *)sender
{
    self.editorViewController.inputMode = (InputMode)sender.selectedSegmentIndex;
    [self configureGestureRecognizer];
}

- (void)configureGestureRecognizer
{
    switch (self.editorViewController.inputMode)
    {
        case InputModeForcePen:
            self.longPressGestureRecognizer.enabled = NO;
            break;
        case InputModeForceTouch:
            self.longPressGestureRecognizer.enabled = YES;
            self.longPressGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect), @(UITouchTypeStylus)];
            break;
        case InputModeAuto:
            self.longPressGestureRecognizer.enabled = YES;
            self.longPressGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect)];
            break;
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ExportSegueId"])
	{
		UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
		ExportTableViewController *exportTableViewController = navController.viewControllers[0];
		exportTableViewController.editor = self.editorViewController.editor;
	}
    else if ([segue.identifier isEqualToString:@"NewPartSegueId"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PartTypesTableViewController *partTypesTableViewController = navController.viewControllers[0];
        if (sender == self)
        {
            if (self.currentPackage)
            {
                // From "File" -> "New"
                partTypesTableViewController.onNewPackage = YES;
                partTypesTableViewController.cancelable = YES;
            }
            else
            {
                // From start
                partTypesTableViewController.onNewPackage = YES;
                partTypesTableViewController.cancelable = NO;
            }
        }
        else
        {
            // From "+" (new part)
            partTypesTableViewController.onNewPackage = NO;
            partTypesTableViewController.cancelable = YES;
        }
    }
}

#pragma mark - More menu

- (void)showMoreMenuWithBlock:(IINKContentBlock *)block position:(CGPoint)p sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect
{
    IINKEditor *editor = self.editorViewController.editor;
    IINKContentBlock *rootBlock = editor.rootBlock;
    
    if ([block.type isEqualToString:@"Container"])
        block = rootBlock;
    
    bool onRawContent = [editor.part.type isEqualToString:@"Raw Content"];
    bool onTextDocument = [editor.part.type isEqualToString:@"Text Document"];
    
    bool isRoot = [block.identifier isEqualToString:[editor rootBlock].identifier];
    bool isEmpty = [editor isEmpty:block];

    NSArray<NSString *> *supportedTypes = editor.supportedAddBlockTypes;
    //NSArray<IINKMimeTypeValue *> *supportedImports = [editor getSupportedImportMimeTypes:block];
    //NSArray<IINKMimeTypeValue *> *supportedExports = [editor getSupportedExportMimeTypes:(onRawContent ? rootBlock : block)];
    NSArray<IINKConversionStateValue *> *supportedStates = [editor getSupportedTargetConversionState:block];
    
    bool hasTypes = supportedTypes.count > 0;
    //bool hasImports = supportedImports.count > 0;
    //bool hasExports = supportedExports.count > 0;
    bool hasStates = supportedStates.count > 0;

    bool displayConvert  = hasStates && !isEmpty;
    bool displayAddBlock = hasTypes && isRoot;
    bool displayAddImage = NO; // hasTypes && isRoot;
    bool displayRemove   = !isRoot;
    bool displayCopy     = onTextDocument ? !isRoot : !onRawContent;
    bool displayPaste    = hasTypes && isRoot;
    bool displayImport   = NO; // hasImports;
    bool displayExport   = NO; // hasExports;

    NSMutableArray<UIAlertAction*> *actions = [NSMutableArray array];

    if (displayAddBlock)
    {
        for (NSUInteger i = 0, count = [supportedTypes count]; i < count; ++i)
        {
            NSString *type = [supportedTypes objectAtIndex:i];
            if ([type isEqualToString:@"Text"])
            {
                UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                    UIAlertController *input = [UIAlertController alertControllerWithTitle:@"Add Text"
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [input addTextFieldWithConfigurationHandler:nil];

                    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [editor addBlock:p type:@"Text" mimeType:IINKMimeTypeText data:input.textFields[0].text error:nil];
                    }];
                    [input addAction:add];

                    [self presentViewController:input animated:YES completion:nil];
                }];
                [actions addObject:add];
            }
            else
            {
                NSString *addTitle = [NSString stringWithFormat:@"Add %@", type];
                UIAlertAction *add = [UIAlertAction actionWithTitle:addTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [editor addBlock:p type:type error:nil];
                }];
                [actions addObject:add];
            }
        }
    }

    if (displayAddImage)
    {
        UIAlertAction *addImage = [UIAlertAction actionWithTitle:@"Add image" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // TODO
        }];
        [actions addObject:addImage];
    }

    if (displayRemove)
    {
        UIAlertAction *remove = [UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [editor removeBlock:block error:nil];
        }];
        [actions addObject:remove];
    }
    
    if (displayConvert)
    {
        UIAlertAction *convert = [UIAlertAction actionWithTitle:@"Convert" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [editor convert:block targetState:supportedStates[0].value error:nil];
        }];
        [actions addObject:convert];
    }
    
    if (displayCopy)
    {
        UIAlertAction *copy = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [editor copy:block error:nil];
        }];
        [actions addObject:copy];
    }

    if (displayPaste)
    {
        UIAlertAction *paste = [UIAlertAction actionWithTitle:@"Paste" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [editor paste:p error:nil];
        }];
        [actions addObject:paste];
    }
    
    if (displayImport)
    {
        UIAlertAction *import = [UIAlertAction actionWithTitle:@"Import" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // TODO
        }];
        [actions addObject:import];
    }

    if (displayExport)
    {
        UIAlertAction *export = [UIAlertAction actionWithTitle:@"Export" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // TODO
        }];
        [actions addObject:export];
    }

    if (actions.count > 0)
    {
        UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
        for (UIAlertAction *action in actions) {
            [menu addAction:action];
        }
        
        UIPopoverPresentationController *popover = menu.popoverPresentationController;
        if (popover)
        {
            popover.sourceView = sourceView;
            popover.sourceRect = sourceRect;
        }
        else
        {
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [menu addAction:cancel];
        }

        [self presentViewController:menu animated:YES completion:nil];
    }
}

- (void)smartGuideViewController:(SmartGuideViewController *)smartGuideViewController didTapOnMoreButton:(UIButton *)moreButton forBlock:(IINKContentBlock *)block
{
    [self showMoreMenuWithBlock:block position:CGPointZero sourceView:moreButton sourceRect:moreButton.bounds];
}

#pragma mark - Gesture recognizer

- (IBAction)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [longPressGestureRecognizer locationInView:longPressGestureRecognizer.view];

        IINKEditor *editor = self.editorViewController.editor;
        IINKContentBlock *block = [editor hitBlock:p];
        if (block == nil)
            block = editor.rootBlock;
        [self showMoreMenuWithBlock:block position:p sourceView:longPressGestureRecognizer.view sourceRect:CGRectMake(p.x, p.y, 1, 1)];

    }
}

#pragma mark - Private methods

/**
 * Load a new part in the editor. Takes care of the UI components update.
 */
- (void)loadPart:(IINKContentPart *)part
{
    IINKEditor *editor = self.editorViewController.editor;
    
    // Reset viewing parameters
    editor.renderer.viewScale = 1;
    editor.renderer.viewOffset = CGPointMake(0, 0);

    // Bind the part to the editor
    [editor setViewSize:self.containerView.bounds.size error:nil];
    editor.part = part;

    self.containerView.userInteractionEnabled = (editor != nil);

    self.undoButton.enabled = YES;
    self.redoButton.enabled = YES;
	self.convertItem.enabled = YES;
	self.moreItem.enabled = YES;

	NSInteger index = [self.currentPackage indexOfPart:editor.part];
	NSInteger partCount = self.currentPackage.partCount;

	self.nextPartItem.enabled = index < partCount - 1;
	self.previousPartItem.enabled = index > 0;
    
    self.title = [NSString stringWithFormat:@"%@ - %@", self.currentFilename, editor.part.type];
}

- (void)unloadPart
{
    self.currentPackage = nil;
    self.editorViewController.editor.part = nil;
    self.title = @"";
}

/**
 * Creates a new package, using name "File%zd.iink" where "%@" is the smallest
 * number for which the resulting file does not exist.
 */
- (void)createPackage
{
    NSArray<File *> *existingIInkFiles = [[FilesController sharedController] iinkFilesFromIInkDirectory];

    NSString *newName = nil;
    int num = 0;
    do
    {
        newName = [NSString stringWithFormat:@"File%d.iink", ++num];
    }
    while ([existingIInkFiles indexOfObjectPassingTest:^BOOL(File * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.filename isEqualToString:newName];
    }] != NSNotFound);

	NSString *fullPath = [[NSFileManager defaultManager] pathForFileInIinkDirectory:newName];
    NSError *error;
	self.currentPackage = [self.engine createPackage:fullPath.decomposedStringWithCanonicalMapping error:&error];
	if (!self.currentPackage)
	{
		UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Error"
		                                                                         message:@"Document already exists"
		                                                                  preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
		                                                   style:UIAlertActionStyleDefault
		                                                 handler:nil];
		[errorController addAction:okAction];
		[self presentViewController:errorController animated:YES completion:nil];
		return;
	}

    self.currentFilename = newName;
	self.addPartItem.enabled = YES;
}

#pragma mark - Engine

- (BOOL)checkEngine
{
    MainNavigationViewController *rootViewController = (MainNavigationViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootViewController.engine != nil)
        return YES;

    NSString *message = rootViewController.engineErrorMessage;
    UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Certificate Error"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         exit(1);
                                                     }];
    [errorController addAction:okAction];
    [self presentViewController:errorController animated:YES completion:nil];
    return NO;
}

- (IINKEngine *)engine
{
	MainNavigationViewController *rootViewController = (MainNavigationViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
	return rootViewController.engine;
}

@end
