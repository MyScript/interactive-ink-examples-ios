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

+ (UIFont *)fontFromStyle:(IINKStyle *)style forString:(NSString*)string
{
    NSString *iOSStyle = style.fontStyle;
    BOOL isItalic = NO;
    BOOL isBold = NO;
    if (style.fontWeight > 600)
        isBold = YES;
    if ([iOSStyle isEqualToString:@"italic"])
        isItalic = YES;
    NSArray<NSString *> *fontFamilies = [[style.fontFamily componentsSeparatedByString:@","] mutableCopy];
    NSString *mainFontFamily = nil;
    NSMutableArray<UIFontDescriptor *> *cascadingFontDescriptors = [[NSMutableArray alloc] init];
    for (NSString *fontFamilyCandidate in fontFamilies) {
        NSString *fontFamily = [fontFamilyCandidate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([fontFamily containsString:@"STIX"])
        {
            if(isItalic)
            {
                fontFamily = @"STIXGeneral-Italic";
            }
            else
            {
                fontFamily = @"STIXGeneral";
            }
        }
        if(!mainFontFamily)
        {
            mainFontFamily = fontFamily;
        }
        else
        {
            CFStringRef name = (__bridge CFStringRef) fontFamily;
            [cascadingFontDescriptors addObject:(__bridge_transfer id)CTFontDescriptorCreateWithNameAndSize(name, style.fontSize)];
        }
    }
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    fontAttributes[(id)kCTFontNameAttribute] = mainFontFamily;
    if([cascadingFontDescriptors count] > 0)
    {
        fontAttributes[(id)kCTFontCascadeListAttribute] = cascadingFontDescriptors;
    }
    CTFontDescriptorRef descriptor  = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)(fontAttributes));
    CTFontRef           cascadeFont = CTFontCreateWithFontDescriptor(descriptor, style.fontSize, NULL);

    CTFontRef           bestFont    = CTFontCreateForString(cascadeFont, (__bridge CFStringRef)(string), CFRangeMake(0, [string length]));
    NSString           *fontName    = CFBridgingRelease(CTFontCopyName(bestFont, kCTFontPostScriptNameKey));

    UIFont   *styledFont            = [UIFont fontWithName:fontName size:style.fontSize];

    if (isItalic)
    {
        styledFont = [styledFont italicFont];
    }
    else if (isBold)
    {
        styledFont = [styledFont boldFont];
    }

    CFRelease(descriptor);
    CFRelease(cascadeFont);
    CFRelease(bestFont);

    return styledFont;
}

+ (UIFont *)fontFromStyle:(IINKStyle *)style
{
    return [UIFont fontFromStyle:style forString:@"a"];
}
@end
