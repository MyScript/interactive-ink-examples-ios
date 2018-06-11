// Copyright MyScript. All right reserved.

#import "EditorViewController.h"
#import "NSFileManager+Additions.h"
#import "ImageLoader.h"

#import "DisplayViewController.h"
#import "SmartGuideViewController.h"
#import "FontMetricsProvider.h"
#import "Helper.h"
#import "InputView.h"
#import <iink/IINKEditor.h>
#import <iink/IINKRenderer.h>
#import <iink/IINKConfiguration.h>

@interface EditorViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) DisplayViewController *displayViewController;
@property (strong, nonatomic) InputView *inputView;
@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) FontMetricsProvider *fontMetricsProvider;

@property (nonatomic) CGPoint originalViewOffset;
@property (nonatomic) float originalScale;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;

@property (nonatomic) BOOL didSetConstraints;

@end

@implementation EditorViewController

- (void)setSmartGuideDisabled:(BOOL)value
{
    if (value)
        self.smartGuideViewController.editor = nil;
    else
        self.smartGuideViewController.editor = self.editor;

    _smartGuideDisabled = value;
}

#pragma mark - Life cycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.containerView];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.opaque = YES;
    
    self.inputView = [[InputView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.inputView];
    self.inputView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputView.backgroundColor = [UIColor clearColor];
    
    [self initDisplayViewController];
    [self initSmartGuideViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    self.panGestureRecognizer.delegate = self;
    self.panGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect)];
    [self.inputView addGestureRecognizer:self.panGestureRecognizer];
    
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizerAction:)];
    self.panGestureRecognizer.delegate = self;
    self.panGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect)];
    [self.inputView addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.inputMode = InputModeForcePen;
}

- (void)initDisplayViewController
{
    self.displayViewController = [[DisplayViewController alloc] init];
    [self addChildViewController:self.displayViewController];
    [self.containerView addSubview:self.displayViewController.view];
    self.displayViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.displayViewController didMoveToParentViewController:self];
}

- (void)initSmartGuideViewController
{
    _smartGuideViewController = [[SmartGuideViewController alloc] init];
    [self addChildViewController:self.smartGuideViewController];
    [self.view addSubview:self.smartGuideViewController.view];
    self.smartGuideViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.smartGuideViewController didMoveToParentViewController:self];
}

#pragma mark -

- (void)setEngine:(IINKEngine *)engine
{
    _engine = engine;
    [self initEditor];
}

- (void)initEditor
{
    ImageLoader *imageLoader = [[ImageLoader alloc] init];
    imageLoader.cacheFolderPath = [[NSFileManager defaultManager] tmpDirectory];
    
    IINKRenderer *renderer = [self.engine createRendererWithDpiX:scaledDpi() dpiY:scaledDpi() target:self.displayViewController error:nil];
    
    self.editor = [self.engine createEditor:renderer];
    [self.editor setViewSize:self.view.bounds.size error:nil];
    self.fontMetricsProvider = [[FontMetricsProvider alloc] init];
    [self.editor setFontMetricsProvider:self.fontMetricsProvider];
    imageLoader.editor = self.editor;
    
    self.displayViewController.renderer = renderer;
    self.displayViewController.imageLoader = imageLoader;
    self.inputView.editor = self.editor;

    self.smartGuideViewController.editor = self.editor;

    IINKConfiguration *conf = self.engine.configuration;
    double horizontalMarginMM = 5;
    double verticalMarginMM = 15;
    [conf setNumber:verticalMarginMM forKey:@"text.margin.top" error:nil];
    [conf setNumber:verticalMarginMM forKey:@"text.margin.top" error:nil];
    [conf setNumber:horizontalMarginMM forKey:@"text.margin.left" error:nil];
    [conf setNumber:horizontalMarginMM forKey:@"text.margin.right" error:nil];
    [conf setNumber:verticalMarginMM forKey:@"math.margin.top" error:nil];
    [conf setNumber:verticalMarginMM forKey:@"math.margin.bottom" error:nil];
    [conf setNumber:horizontalMarginMM forKey:@"math.margin.left" error:nil];
    [conf setNumber:horizontalMarginMM forKey:@"math.margin.right" error:nil];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.editor setViewSize:self.view.bounds.size error:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.inputMode != InputModeForcePen && self.editor.isScrollAllowed;
}

#pragma mark - Pan gesture recognizer (scroll page)

- (IBAction)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!self.editor) {
        return;
    }
    
    if (!self.editor.isScrollAllowed) {
        return;
    }
    
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.originalViewOffset = self.editor.renderer.viewOffset;
    }
    
    CGPoint newOffset = CGPointMake(self.originalViewOffset.x - translation.x, self.originalViewOffset.y - translation.y);
    [self.editor clampViewOffset:&newOffset];
    [self.editor.renderer setViewOffset:newOffset];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.originalViewOffset = self.editor.renderer.viewOffset;
    }
    
    [self.displayViewController refreshViews];
}

#pragma mark - Pinch gesture recognizer (zoom/unzoom page)

- (IBAction)pinchGestureRecognizerAction:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (!self.editor) {
        return;
    }
    
    if (!self.editor.isScrollAllowed) {
        return;
    }
    
    CGPoint pinchCenter = [pinchGestureRecognizer locationInView:self.view];
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.originalScale = self.editor.renderer.viewScale;
    }
    
    float previousScale = self.editor.renderer.viewScale;
    float newScale = (float)(self.originalScale * pinchGestureRecognizer.scale);

    [self.editor.renderer zoom:pinchCenter by:newScale / previousScale error:nil];
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.originalScale = self.editor.renderer.viewScale;
    }
    
    [self.displayViewController refreshViews];
}

#pragma mark - Input mode

- (void)setInputMode:(InputMode)inputMode
{
    _inputMode = inputMode;

    switch (inputMode)
    {
        case InputModeForcePen:
            self.panGestureRecognizer.enabled = NO;
            self.pinchGestureRecognizer.enabled = NO;
            break;
        case InputModeForceTouch:
            self.panGestureRecognizer.enabled = YES;
            self.panGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect), @(UITouchTypeStylus)];
            self.pinchGestureRecognizer.enabled = YES;
            self.pinchGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect), @(UITouchTypeStylus)];
            break;
        case InputModeAuto:
            self.panGestureRecognizer.enabled = YES;
            self.panGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect)];
            self.pinchGestureRecognizer.enabled = YES;
            self.pinchGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeDirect)];
            break;
    }

    self.inputView.inputMode = inputMode;
}

#pragma mark - Constraints

- (void)updateViewConstraints
{
    [self initViewConstraints];
    [super updateViewConstraints];
}

- (void)initViewConstraints
{
    if (!self.didSetConstraints)
    {
        self.didSetConstraints = YES;
        
        NSDictionary *views = @{@"containerView" : self.containerView, @"displayViewControllerView" : self.displayViewController.view, @"inputView" : self.inputView};

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[inputView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[inputView]|" options:0 metrics:nil views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[displayViewControllerView]|" options:0 metrics:nil views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[displayViewControllerView]|" options:0 metrics:nil views:views]];
    }
}

@end
