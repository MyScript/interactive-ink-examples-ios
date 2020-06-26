// Copyright @ MyScript. All rights reserved.

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
    NSString *fontFamily = style.fontFamily;

    if ([fontFamily containsString:@"STIX"])
    {
        if ([style.fontStyle isEqualToString:@"italic"])
        {
            fontFamily = @"STIXGeneral-Italic";
        }
        else
        {
            fontFamily = @"STIXGeneral";
        }
    }

    NSString *lowerCaseFontFamily = [fontFamily lowercaseString];
    BOOL isLight = NO;
    BOOL isItalic = NO;
    BOOL isBold = NO;
    if (style.fontWeight > 600)
        isBold = YES;
    if (style.fontWeight < 400 || [lowerCaseFontFamily containsString:@"light"])
        isLight = YES;
    if ([style.fontStyle isEqualToString:@"italic"])
        isItalic = YES;

    CTFontRef cascadeFont = nullptr;
    if ([fontFamily isEqualToString:@"sans-serif"])
    {
      UIFont *font = nil;
      NSOperatingSystemVersion minimumVersion;
      minimumVersion.majorVersion = 13;
      minimumVersion.minorVersion = 0;
      minimumVersion.patchVersion = 0;
      BOOL useSystemFont = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:minimumVersion];
      if (useSystemFont)
      {
          font = [UIFont systemFontOfSize:style.fontSize weight:UIFontWeightRegular];

      }
      else
      {
          font = [UIFont fontWithName:@".SFUIText" size:style.fontSize];
      }
      cascadeFont = (CTFontRef)CFBridgingRetain(font);
    }
    else
    {
        NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
        fontAttributes[(id)kCTFontNameAttribute] = fontFamily;
        if ([fontFamily containsString:@"STIX"])
        {
            fontAttributes[(id)kCTFontCascadeListAttribute] = @[
            (__bridge_transfer id)CTFontDescriptorCreateWithNameAndSize(CFSTR("STIXGeneral"), style.fontSize),
                                                                (__bridge_transfer id)CTFontDescriptorCreateWithNameAndSize(CFSTR("STIXGeneral-Italic"), style.fontSize),
                                                                ];
        }
        CTFontDescriptorRef descriptor  = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)(fontAttributes));
        cascadeFont           = CTFontCreateWithFontDescriptor(descriptor, style.fontSize, NULL);
        CFRelease(descriptor);
    }

    CTFontRef        bestFont = CTFontCreateForString(cascadeFont, (__bridge CFStringRef)(string), CFRangeMake(0, [string length]));
    UIFont           *font    = (__bridge UIFont*)bestFont;

    if (isItalic)
    {
        font = [font italicFont];
    }
    else if (isBold)
    {
        font = [font boldFont];
    }

    CFRelease(cascadeFont);
    CFRelease(bestFont);

    return font;
}

+ (UIFont *)fontFromStyle:(IINKStyle *)style
{
    return [UIFont fontFromStyle:style forString:@"a"];
}

@end
