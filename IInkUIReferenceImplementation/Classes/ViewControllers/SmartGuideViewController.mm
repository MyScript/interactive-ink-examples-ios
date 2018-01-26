// Copyright MyScript. All right reserved.

#import "SmartGuideViewController.h"
#import "IInkUIRefImplUtils.h"
#import <iink/IINKRenderer.h>

/** The gray color used for controls (buttons and ruler). */
#define CONTROL_GRAY_COLOR [IInkUIRefImplUtils uiColor:0x959DA6ff]
/** The gray color used for displayed words. */
#define WORD_GRAY_COLOR [IInkUIRefImplUtils uiColor:0xbfbfbfff]

typedef NS_ENUM(NSUInteger, UpdateCause)
{
    /** A visual change occurred. */
    UpdateCauseVisual,
    /** An edit occurred (writing or editing gesture). */
    UpdateCauseEdit,
    /** The selection changed. */
    UpdateCauseSelection,
    /** View parameters changed (scroll or zoom). */
    UpdateCauseView
};

typedef NS_ENUM(NSUInteger, TextBlockStyle)
{
    TextBlockStyleH1,
    TextBlockStyleH2,
    TextBlockStyleH3,
    TextBlockStyleNormal
};


// -- SmartGuideWord -----------------------------------------------------------

@interface SmartGuideWord : NSObject
{

}

@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSArray<NSString *> *candidates;
@property (nonatomic) BOOL modified;

- (nullable instancetype)initWithJson:(NSDictionary *)object;
+ (nullable SmartGuideWord *)valueWithJson:(NSDictionary *)object;

@end

@implementation SmartGuideWord

- (nullable instancetype)initWithJson:(NSDictionary *)object
{
    self = [super init];
    if (self)
    {
        self.label = [object objectForKey:@"label"];
        self.candidates = [object objectForKey:@"candidates"];
        self.modified = NO;
    }
    return self;
}

+ (nullable SmartGuideWord *)valueWithJson:(NSDictionary *)object
{
    return [[SmartGuideWord alloc] initWithJson:object];
}

@end


// -- SmartGuideWordView -------------------------------------------------------

@class SmartGuideWordView;

@protocol SmartGuideWordViewDelegate <NSObject>

- (void)smartGuideWordViewDidReceiveTap:(SmartGuideWordView *)smartGuideWordView;

@end

@interface SmartGuideWordView : UILabel
{
}

@property (strong, nonatomic) SmartGuideWord *word;
@property (nonatomic) NSUInteger index;
@property (weak, nonatomic) id<SmartGuideWordViewDelegate> delegate;

@end

@implementation SmartGuideWordView

- (nullable instancetype)initWithWord:(SmartGuideWord *)word index:(NSUInteger)index isWhitespace:(BOOL)isWhitespace
{
    self = [super init];
    if (self)
    {
        self.word = word;
        self.index = index;
        self.text = isWhitespace ? @" " : word.label;

        if (word.candidates && word.candidates.count > 1)
        {
            self.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self addGestureRecognizer:tapGesture];
        }

        if (word.modified)
        {
            self.textColor = [UIColor blackColor];
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeHighlightTimerFireMethod:) userInfo:nil repeats:NO];
        }
        else
        {
            self.textColor = WORD_GRAY_COLOR;
        }
    }
    return self;
}

- (IBAction)tap:(UITapGestureRecognizer*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(smartGuideWordViewDidReceiveTap:)])
        [self.delegate smartGuideWordViewDidReceiveTap:self];
}

- (void)removeHighlightTimerFireMethod:(NSTimer *)timer
{
    self.textColor = WORD_GRAY_COLOR;
}

@end


// -- SmartGuideViewController -------------------------------------------------

@interface SmartGuideViewController () <IINKEditorDelegate, IINKRendererDelegate, SmartGuideWordViewDelegate>

@property (strong, nonatomic) UIButton *styleButton;
@property (strong, nonatomic) UIScrollView *wordScrollView;
@property (strong, nonatomic) UIStackView *wordStackView;
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) UIView *rulerView;

@property (nonatomic) BOOL didSetConstraints;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) IINKContentBlock *activeBlock;
@property (strong, nonatomic) IINKContentBlock *selectedBlock;
@property (strong, nonatomic) IINKContentBlock *block;
@property (strong, nonatomic) NSArray<SmartGuideWord *> *words;
@property (strong, nonatomic) NSTimer *fadeOutTimer;

@end

@implementation SmartGuideViewController

#pragma mark - Life cycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:.95f];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.hidden = YES;

    self.styleButton = [[UIButton alloc] init];
    self.styleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.styleButton];

    self.wordScrollView = [[UIScrollView alloc] init];
    self.wordScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.wordScrollView];

    self.wordStackView = [[UIStackView alloc] init];
    self.wordStackView.axis = UILayoutConstraintAxisHorizontal;
    self.wordStackView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
    self.wordStackView.layoutMarginsRelativeArrangement = YES;
    self.wordStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.wordScrollView addSubview:self.wordStackView];

    self.moreButton = [[UIButton alloc] init];
    [self.moreButton setTitle:@"•••" forState:UIControlStateNormal];
    [self.moreButton setTitleColor:CONTROL_GRAY_COLOR forState:UIControlStateNormal];
    self.moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.moreButton];

    self.rulerView = [[UIView alloc] init];
    self.rulerView.userInteractionEnabled = NO;
    self.rulerView.backgroundColor = CONTROL_GRAY_COLOR;
    self.rulerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.rulerView];

    [self.moreButton addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Constraints

- (void)updateViewConstraints
{
    if (!self.didSetConstraints)
    {
        self.didSetConstraints = YES;

        NSDictionary *views = @{@"styleButton": self.styleButton, @"wordScrollView": self.wordScrollView, @"moreButton": self.moreButton, @"rulerView": self.rulerView};

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[styleButton][wordScrollView][moreButton]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[styleButton][rulerView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[styleButton]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wordScrollView][rulerView(1)]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[moreButton]|" options:0 metrics:nil views:views]];

        self.leftConstraint = [self.view.leftAnchor constraintEqualToAnchor:self.view.superview.leftAnchor constant:0];
        self.topConstraint = [self.view.topAnchor constraintEqualToAnchor:self.view.superview.topAnchor constant:0];
        self.widthConstraint = [self.view.widthAnchor constraintEqualToConstant:100];
        self.leftConstraint.active = YES;
        self.topConstraint.active = YES;
        self.widthConstraint.active = YES;

        // Pin the edges of the stack view to the edges of the scroll view
        [self.wordStackView.leadingAnchor constraintEqualToAnchor:self.wordScrollView.leadingAnchor].active = true;
        [self.wordStackView.trailingAnchor constraintEqualToAnchor:self.wordScrollView.trailingAnchor].active = true;
        [self.wordStackView.bottomAnchor constraintEqualToAnchor:self.wordScrollView.bottomAnchor].active = true;
        [self.wordStackView.topAnchor constraintEqualToAnchor:self.wordScrollView.topAnchor].active = true;
    }
    [super updateViewConstraints];
}

#pragma mark -

- (void)setEditor:(IINKEditor *)editor
{
    _editor = editor;

    [self.editor addDelegate:self];
    [self.editor.renderer addDelegate:self];
}

- (void)setTextBlockStyle:(TextBlockStyle)textBlockStyle
{
    switch (textBlockStyle)
    {
        case TextBlockStyleH1:
            [self.styleButton setTitle:@"H1" forState:UIControlStateNormal];
            [self.styleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.styleButton setBackgroundColor:[UIColor blackColor]];
            self.styleButton.layer.borderWidth = 0.f;
            break;

        case TextBlockStyleH2:
            [self.styleButton setTitle:@"H2" forState:UIControlStateNormal];
            [self.styleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.styleButton setBackgroundColor:CONTROL_GRAY_COLOR];
            self.styleButton.layer.borderWidth = 0.f;
            break;

        case TextBlockStyleH3:
            [self.styleButton setTitle:@"H3" forState:UIControlStateNormal];
            [self.styleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.styleButton setBackgroundColor:CONTROL_GRAY_COLOR];
            self.styleButton.layer.borderWidth = 0.f;
            break;

        case TextBlockStyleNormal:
        default:
            [self.styleButton setTitle:@"¶" forState:UIControlStateNormal];
            [self.styleButton setTitleColor:CONTROL_GRAY_COLOR forState:UIControlStateNormal];
            [self.styleButton setBackgroundColor:[UIColor whiteColor]];
            self.styleButton.layer.borderWidth = 1.f;
            self.styleButton.layer.borderColor = CONTROL_GRAY_COLOR.CGColor;
            break;
    }
}

- (void)computeModificationOfWords:(NSArray<SmartGuideWord *> *)words againstWords:(NSArray<SmartGuideWord *> *)oldWords
{
    int len1 = (int)oldWords.count;
    int len2 = (int)words.count;

    int d[len1 + 1][len2 + 1];
    int i;
    int j;

    // Levenshtein distance algorithm at word level
    d[0][0] = 0;
    for (i = 1; i <= len1; ++i)
        d[i][0] = i;
    for (i = 1; i <= len2; ++i)
        d[0][i] = i;

    for (i = 1; i <= len1; ++i)
    {
        for (j = 1; j <= len2; ++j)
        {
            int d1 = d[i - 1][j] + 1;
            int d2 = d[i][j - 1] + 1;
            int d3 = d[i - 1][j - 1] + ([oldWords[i - 1].label isEqualToString:words[j - 1].label] ? 0 : 1);
            d[i][j] = MIN(MIN(d1, d2), d3);
        }
    }

    // Backward traversal
    for (j = 0; j < len2; ++j)
        words[j].modified = true;

    if ( (len1 > 0) && (len2 > 0) )
    {
        i = len1;
        j = len2;

        while (j > 0)
        {
            int d01 = d[i][j-1];
            int d11 = (i > 0) ? d[i-1][j-1] : -1;
            int d10 = (i > 0) ? d[i-1][j] : -1;

            if ( (d11 >= 0) && (d11 <= d10) && (d11 <= d01) )
            {
                --i;
                --j;
            }
            else if ( (d10 >= 0) && (d10 <= d11) && (d10 <= d01) )
            {
                --i;
            }
            else //if ( (d01 <= d11) && (d01 <= d10) )
            {
                --j;
            }

            if ( (i < len1) && (j < len2) )
                words[j].modified = ![oldWords[i].label isEqualToString:words[j].label];
        }
    }
}

- (void)updateWithBlock:(IINKContentBlock *)block cause:(UpdateCause)cause
{
    if (self.fadeOutTimer)
    {
        [self.fadeOutTimer invalidate];
        self.fadeOutTimer = nil;
    }

    if (block && [block.type isEqualToString:@"Text"])
    {
        // Update size and position
        CGRect rectangle = block.box;
        float paddingLeft = 0.0f;
        float paddingRight = 0.0f;
        if (block.attributes.length > 0)
        {
            NSData *attributesData = [block.attributes dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:attributesData options:0 error:nil];
            NSDictionary *padding = [attributes objectForKey:@"padding"];
            if (padding)
            {
                paddingLeft = ((NSNumber *)[padding objectForKey:@"left"]).floatValue;
                paddingRight = ((NSNumber *)[padding objectForKey:@"right"]).floatValue;
            }
        }
        CGAffineTransform transform = self.editor.renderer.viewTransform;
        CGPoint origin = CGPointApplyAffineTransform(CGPointMake(rectangle.origin.x + paddingLeft, rectangle.origin.y), transform);
        CGSize size = CGSizeApplyAffineTransform(CGSizeMake(rectangle.size.width - paddingLeft - paddingRight, rectangle.size.height), transform);
        float x = origin.x;
        float y = origin.y;
        float width = size.width;

        // Update words
        NSArray<SmartGuideWord *> *words;
        BOOL isSameActiveBlock = self.block && [self.block.identifier isEqualToString:block.identifier];
        if (cause != UpdateCauseEdit && isSameActiveBlock)
        {
            // Nothing changed so keep same words
            words = self.words;
        }
        else
        {
            // Build new word list from JIIX export
            NSError *error = nil;
            NSString *jiixStr = [self.editor export_:block mimeType:IINKMimeTypeJIIX error:&error];
            if (error)
                return; // when processing is ongoing, export may fail: ignore
            NSData *jiixData = [jiixStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jiix = [NSJSONSerialization JSONObjectWithData:jiixData options:0 error:nil];
            NSArray<NSDictionary *> *jiixWords = [jiix objectForKey:@"words"];
            NSMutableArray<SmartGuideWord *> *words_ = [NSMutableArray arrayWithCapacity:jiixWords.count];
            for (NSDictionary *jiixWord in jiixWords)
                [words_ addObject:[SmartGuideWord valueWithJson:jiixWord]];
            words = words_;

            // Possibly compute difference with previous state
            if (isSameActiveBlock)
                [self computeModificationOfWords:words againstWords:self.words];
            else if (cause == UpdateCauseEdit)
                [words enumerateObjectsUsingBlock:^(SmartGuideWord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { obj.modified = YES; }];
        }

        TextBlockStyle textBlockStyle = TextBlockStyleNormal;
        BOOL updateWords = words != self.words;
        BOOL isInDiagram = [block.identifier hasPrefix:@"diagram/"];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.leftConstraint.constant = x;
            self.topConstraint.constant = y - self.view.frame.size.height;
            self.widthConstraint.constant = width;
            [self setTextBlockStyle:textBlockStyle];
            if (updateWords)
            {
                SmartGuideWordView *lastModifiedWordView = nil;
                [[self.wordStackView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                BOOL previousWasWhitespace = NO;
                for (NSUInteger i = 0; i < words.count; ++i)
                {
                    BOOL isWhitespace = [words[i].label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
                    if (isWhitespace && previousWasWhitespace)
                        continue;
                    SmartGuideWordView *wordView = [[SmartGuideWordView alloc] initWithWord:words[i] index:i isWhitespace:isWhitespace];
                    wordView.translatesAutoresizingMaskIntoConstraints = NO;
                    [self.wordStackView addArrangedSubview:wordView];
                    [wordView.heightAnchor constraintEqualToAnchor:self.wordScrollView.heightAnchor multiplier:1].active = YES;
                    wordView.delegate = self;
                    if (wordView.word.modified)
                        lastModifiedWordView = wordView;
                    previousWasWhitespace = isWhitespace;
                }
                if (lastModifiedWordView)
                {
                    [self.wordScrollView layoutIfNeeded];
                    CGRect rect = [self.wordScrollView convertRect:lastModifiedWordView.frame fromView:self.wordStackView];
                    [self.wordScrollView scrollRectToVisible:rect animated:YES];
                }
            }
            self.view.hidden = NO;
            if (isInDiagram && cause == UpdateCauseEdit)
            {
                self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fadeOutTimerFireMethod:) userInfo:nil repeats:NO];
            }
        }];

        self.block = block;
        self.words = words;
    }
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.view.hidden = YES;
        }];

        self.block = nil;
    }

}

- (void)fadeOutTimerFireMethod:(NSTimer *)timer
{
    self.fadeOutTimer = nil;
    self.view.hidden = YES;
}

- (void)smartGuideWordViewDidReceiveTap:(SmartGuideWordView *)smartGuideWordView
{
    if (self.fadeOutTimer)
    {
        [self.fadeOutTimer invalidate];
        self.fadeOutTimer = nil;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSUInteger i = 0; i < smartGuideWordView.word.candidates.count; ++i)
    {
        NSString *label = smartGuideWordView.word.candidates[i];
        BOOL selected = [label isEqualToString:smartGuideWordView.word.label];
        UIAlertAction *action = [UIAlertAction actionWithTitle:label style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (!selected)
            {
                smartGuideWordView.word.label = label;
                smartGuideWordView.text = label;

                NSString *jiixStr = [self.editor export_:self.block mimeType:IINKMimeTypeJIIX error:nil];
                NSData *jiixData = [jiixStr dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jiix_ = [NSJSONSerialization JSONObjectWithData:jiixData options:0 error:nil];
                NSMutableDictionary *jiix = [jiix_ mutableCopy];
                NSArray<NSDictionary *> *jiixWords_ = [jiix objectForKey:@"words"];
                NSMutableArray<NSDictionary *> *jiixWords = [jiixWords_ mutableCopy];
                NSDictionary *jiixWord_ = jiixWords[smartGuideWordView.index];
                NSDictionary *jiixWord = [jiixWord_ mutableCopy];
                [jiixWord setValue:label forKey:@"label"];
                jiixWords[smartGuideWordView.index] = jiixWord;
                [jiix setObject:jiixWords forKey:@"words"];
                jiixData = [NSJSONSerialization dataWithJSONObject:jiix options:0 error:nil];
                jiixStr = [[NSString alloc] initWithData:jiixData encoding:NSUTF8StringEncoding];
                [self.editor import_:IINKMimeTypeJIIX data:jiixStr block:self.block error:nil];
            }
        }];
        [alertController addAction:action];
    }

    UIPopoverPresentationController *popover = [alertController popoverPresentationController];
    if (popover)
    {
        [popover setPermittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown];
        [popover setSourceView:smartGuideWordView];
        [popover setSourceRect:smartGuideWordView.bounds];
    }
    else
    {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)moreButtonTapped:(UIButton *)sender
{
    if (self.fadeOutTimer)
    {
        [self.fadeOutTimer invalidate];
        self.fadeOutTimer = nil;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(smartGuideViewController:didTapOnMoreButton:forBlock:)])
        [self.delegate smartGuideViewController:self didTapOnMoreButton:sender forBlock:self.block];
}

- (void)partChanged:(nonnull IINKEditor*)editor
{
    self.activeBlock = self.selectedBlock = nil;
    [self updateWithBlock:nil cause:UpdateCauseVisual];
}

- (void)contentChanged:(nonnull IINKEditor*)editor blockIds:(nonnull NSArray<NSString *> *)blockIds
{
    // The active block may have been removed then added again in which case
    // the old instance is invalid but can be restored by remapping the identifier
    if (self.activeBlock && !self.activeBlock.valid)
    {
        self.activeBlock = [self.editor getBlockById:self.activeBlock.identifier];
        if (!self.activeBlock)
        {
            [self updateWithBlock:nil cause:UpdateCauseEdit];
            return;
        }
    }

    if (self.activeBlock && [blockIds containsObject:self.activeBlock.identifier])
    {
        if (!self.block)
            self.block = self.activeBlock;
        [self updateWithBlock:self.activeBlock cause:UpdateCauseEdit];
    }
}

- (void)selectionChanged:(nonnull IINKEditor*)editor blockIds:(nonnull NSArray<NSString *> *)blockIds
{
    self.selectedBlock = nil;
    for (NSString *blockId in blockIds)
    {
        IINKContentBlock *block = [self.editor getBlockById:blockId];
        if (block && [block.type isEqualToString:@"Text"])
        {
            self.selectedBlock = block;
            break;
        }
    }
    [self updateWithBlock:self.selectedBlock cause:UpdateCauseSelection];
}

- (void)activeBlockChanged:(IINKEditor *)editor blockId:(NSString *)blockId
{
    self.activeBlock = [self.editor getBlockById:blockId];
    if (self.block && [self.block.identifier isEqualToString:blockId])
        return; // selectionChanged already changed the active block
    [self updateWithBlock:self.activeBlock cause:UpdateCauseEdit];
}

- (void)onError:(nonnull IINKEditor*)editor
        blockId:(nonnull NSString*)blockId
        message:(nonnull NSString*)message
{

}

- (void)viewTransformChanged:(IINKRenderer *)renderer
{
    [self updateWithBlock:self.block cause:UpdateCauseView];
}

@end
