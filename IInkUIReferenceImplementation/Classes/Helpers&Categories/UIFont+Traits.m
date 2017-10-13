// Copyright MyScript. All right reserved.

#import "UIFont+Traits.h"
#import <CoreText/CoreText.h>

@implementation UIFont (Traits)

- (UIFont *)italicFont
{
    // Use standard mechanism to get the italic font
    CTFontRef ctFont                   = CTFontCreateWithName((CFStringRef)self.fontName, self.pointSize, NULL);
    CTFontRef italicCtFont             = CTFontCreateCopyWithSymbolicTraits(ctFont, self.pointSize, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    NSString *italicFontPostScriptName = (NSString *)CFBridgingRelease(CTFontCopyPostScriptName(italicCtFont));
    UIFont   *italicFont               = [UIFont fontWithName:italicFontPostScriptName size:self.pointSize];
    
    if (ctFont)
    {
        CFRelease(ctFont);
    }
    if (italicCtFont)
    {
        CFRelease(italicCtFont);
    }
    
    // The standard mechanism may fail for custom fonts. In this case, retrieve the italic font
    // manually by looking for font of the same family with "italic" or "oblique" in the name.
    if (![italicFont isItalic])
    {
        for (NSString *aFontName in [UIFont fontNamesForFamilyName:[self familyName]])
        {
            if ([aFontName rangeOfString:@"italic" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [aFontName rangeOfString:@"oblique" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                italicFont = [UIFont fontWithName:aFontName size:self.pointSize];
            }
        }
    }
    
    return italicFont ?: self;
}

- (UIFont *)boldFont
{
    // Use standard mechanism to get the bold font
    CTFontRef ctFont             = CTFontCreateWithName((CFStringRef)self.fontName, self.pointSize, NULL);
    CTFontRef boldCtFont       = CTFontCreateCopyWithSymbolicTraits(ctFont, self.pointSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    NSString *fontPostScriptName = (NSString *)CFBridgingRelease(CTFontCopyPostScriptName(boldCtFont));
    UIFont   *boldFont         = [UIFont fontWithName:fontPostScriptName size:self.pointSize];
    
    if (ctFont)
    {
        CFRelease(ctFont);
    }
    if (boldCtFont)
    {
        CFRelease(boldCtFont);
    }
    
    // The standard mechanism may fail for custom fonts. In this case, retrieve the bold font
    // manually by looking for font of the same family with "bold" in the name.
    if (![boldFont isBold])
    {
        for (NSString *aFontName in [UIFont fontNamesForFamilyName:[self familyName]])
        {
            if ([aFontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                boldFont = [UIFont fontWithName:aFontName size:self.pointSize];
            }
        }
    }
    
    return boldFont ?: self;
}

- (BOOL)isItalic
{
    CTFontRef            fontRef        = (CTFontRef)CFBridgingRetain(self);
    CTFontSymbolicTraits symbolicTraits = CTFontGetSymbolicTraits(fontRef);
    
    CFRelease(fontRef);
    
    return (symbolicTraits & kCTFontTraitItalic);
}

- (BOOL)isBold
{
    CTFontRef            fontRef        = (CTFontRef)CFBridgingRetain(self);
    CTFontSymbolicTraits symbolicTraits = CTFontGetSymbolicTraits(fontRef);
    
    CFRelease(fontRef);
    
    return (symbolicTraits & kCTFontTraitBold);
}

@end
