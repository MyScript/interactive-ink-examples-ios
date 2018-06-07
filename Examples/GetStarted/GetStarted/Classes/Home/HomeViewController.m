// Copyright MyScript. All right reserved.

#import "HomeViewController.h"
#import <IInkUIReferenceImplementation/IInkUIReferenceImplementation.h>
#import "AppDelegate.h"

@interface HomeViewController ()

@property (weak, nonatomic) EditorViewController *editorViewController;

@property (weak, nonatomic) IBOutlet UISegmentedControl *inputTypeSegmentedControl;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (![self checkEngine])
        return;

    self.editorViewController = (EditorViewController *)self.childViewControllers.firstObject;
    self.editorViewController.engine = self.engine;
    
    self.editorViewController.inputMode = InputModeForcePen; // We want the Pen mode for this GetStarted sample code. It lets the user use either its mouse or fingers to draw.
    // If you have got an iPad Pro with a Apple Pencil, please set this value to InputModeAuto for a better experience.
    
    self.inputTypeSegmentedControl.selectedSegmentIndex = (NSInteger)self.editorViewController.inputMode;
    
    IINKContentPackage *package = [self createPackageWithName:@"NewPackage"];
    [self.editorViewController.editor setPart:[package getPartAt:0 error:nil]];
}

- (IINKContentPackage *)createPackageWithName:(NSString *)name
{
    // Create a new content package with name
    NSString *fullPath = [[[NSFileManager defaultManager] pathForFileInDocumentDirectory:name] stringByAppendingPathExtension:@"iink"];
    IINKEngine *engine = ((AppDelegate *)[UIApplication sharedApplication].delegate).engine;
    IINKContentPackage *package = [engine createPackage:fullPath.decomposedStringWithCanonicalMapping error:nil];
    
    // Add a blank page type Text Document
    IINKContentPart *part = [package createPart:@"Text Document" error:nil]; // Options are : "Diagram", "Drawing", "Math", "Text Document", "Text"
    
    self.title = [NSString stringWithFormat:@"Type: %@", part.type];
    return package;
}

#pragma mark - Buttons actions

- (IBAction)clearButtonWasTouchedUpInside:(id)sender
{
    [self.editorViewController.editor clear];
}

- (IBAction)undoButtonWasTouchedUpInside:(id)sender
{
    [self.editorViewController.editor undo];
}

- (IBAction)redoButtonWasTouchedUpInside:(id)sender
{
    [self.editorViewController.editor redo];
}

- (IBAction)convertButtonWasTouchedUpInside:(id)sender
{
    NSArray<IINKConversionStateValue *> *supportedStates = [self.editorViewController.editor getSupportedTargetConversionState:nil];
    if (supportedStates.count > 0)
        [self.editorViewController.editor convert:nil
                                      targetState:supportedStates[0].value
                                            error:nil];
}

#pragma mark - Segmented control actions

- (IBAction)inputTypeSegmenedControlValueChanged:(UISegmentedControl *)sender
{
    self.editorViewController.inputMode = (InputMode)sender.selectedSegmentIndex;
}

#pragma mark - Engine

- (BOOL)checkEngine
{
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.engine != nil)
        return YES;

    NSString *message = appDelegate.engineErrorMessage;
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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.engine;
}

@end
