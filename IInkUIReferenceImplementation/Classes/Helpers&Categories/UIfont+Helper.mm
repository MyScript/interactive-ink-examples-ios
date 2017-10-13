// Copyright MyScript. All right reserved.

#import <CoreText/CoreText.h>

#import "UIfont+Helper.h"
#import "UIFont+Traits.h"

#import <algorithm>
#import <string>

#import <iink/graphics/IINKStyle.h>

@implementation UIFont (Helper)

#pragma mark - Custom Fonts

+ (void)loadCustomFontsFromBundle:(NSBundle *)bundle
{
    if (bundle)
    {
        // Load custom fonts from bundle
        NSArray *ttfFontsPaths = [bundle pathsForResourcesOfType:@"ttf" inDirectory:nil];
        NSArray *otfFontsPaths = [bundle pathsForResourcesOfType:@"otf" inDirectory:nil];
        
        NSMutableArray *allFontsPath = [NSMutableArray array];
        
        [allFontsPath addObjectsFromArray:ttfFontsPaths];
        [allFontsPath addObjectsFromArray:otfFontsPaths];
        
        for (NSString *aFontPath in allFontsPath)
        {
            [self loadFont:aFontPath];
        }
    }
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // The first use of custom fonts by Core Text is slow (then it is cached). So to avoid this
        // slowness to happen during first typesetting, we immediatly force the loading process by
        // simulating a typesetting call.
        [UIFont fontWithName:@"STIXGeneral" size:10];
    }
     
     ];
}

// To be able to load custom fonts as a UIFont, we need to register them.
+ (void)loadFont:(NSString *)fontPath
{
    if (fontPath)
    {
        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);
        CGFontRef         customFont       = CGFontCreateWithDataProvider(fontDataProvider);
        CGDataProviderRelease(fontDataProvider);
        CFErrorRef error = nil;
        CTFontManagerRegisterGraphicsFont(customFont, &error);
        
        if (error != nil)
        {
            NSError *err = (__bridge NSError *)error;
            if (err.code != 105) // Code 105 = Font already loaded (storyboard for example)
                NSLog(@"Error loading font %@ (%@)", fontPath, [err description]);
        }
        
        CGFontRelease(customFont);
    }
}

#pragma mark - ATK

+ (UIFont *)fontFromStyle:(IINKStyle *)style
{
    NSString *fontFamily = style.fontFamily;
    NSString *iOSStyle = style.fontStyle;
    BOOL isItalic = NO;
    BOOL isBold = NO;
    if (style.fontWeight > 600)
        isBold = YES;
    if ([iOSStyle isEqualToString:@"italic"])
        isItalic = YES;
    
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    fontAttributes[(id)kCTFontNameAttribute] = fontFamily;
    
    // TODO: Fix font naming problems
    if ([fontFamily containsString:@"STIX"])
    {
        fontFamily = @"STIXGeneral";
    }
    
    if ([fontFamily containsString:@"STIX"])
    {
        fontAttributes[(id)kCTFontNameAttribute]        = fontFamily;
        fontAttributes[(id)kCTFontCascadeListAttribute] = @[
                                                            (__bridge_transfer id)CTFontDescriptorCreateWithNameAndSize(CFSTR("STIXGeneral"), style.fontSize),
                                                            (__bridge_transfer id)CTFontDescriptorCreateWithNameAndSize(CFSTR("STIXGeneral-Italic"), style.fontSize),
                                                            ];
    }
    
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
    UIFont *styledFont = [UIFont fontWithDescriptor:fontDescriptor size:style.fontSize];
    
    if (!styledFont)
        styledFont = [UIFont systemFontOfSize:style.fontSize];
    
    if (isItalic)
    {
        styledFont = [styledFont italicFont];
    }
    else if (isBold)
    {
        styledFont = [styledFont boldFont];
    }
    
    return styledFont;
}

@end
