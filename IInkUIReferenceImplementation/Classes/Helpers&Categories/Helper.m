// Copyright MyScript. All right reserved.

#import "Helper.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <sys/types.h>
#include <sys/sysctl.h>

#define DPI_PHONE           326
#define DPI_PHONE_PLUS      401
#define DPI_PHONE_X         463

#define DPI_PAD             132
#define DPI_PAD_MINI        163
#define DPI_PAD_MINI_RETINA 324
#define DPI_PAD_RETINA      264

static BOOL isPad() {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

static BOOL isPadMini()
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = (char*) malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
        if ([platform isEqualToString:@"iPad2,5"]
            || [platform isEqualToString:@"iPad2,6"]
            || [platform isEqualToString:@"iPad2,7"])
            return YES;
    }
    return NO;
}

static BOOL isPadMiniRetina()
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = (char*) malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
        if ([platform isEqualToString:@"iPad4,4"]
            || [platform isEqualToString:@"iPad4,4"]
            || [platform isEqualToString:@"iPad4,6"]
            || [platform isEqualToString:@"iPad4,7"]
            || [platform isEqualToString:@"iPad4,8"]
            || [platform isEqualToString:@"iPad4,9"])
            return YES;
    }
    return NO;
}

static BOOL isPhone()
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

static BOOL isPhoneX()
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] nativeBounds].size.height == 2436);
}

static BOOL isPhonePlus()
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].scale > 2);
}

static float dpi()
{
    if (isPhone())
    {
        if (isPhoneX())
        {
            return DPI_PHONE_X;
        }
        else if (isPhonePlus())
        {
            return DPI_PHONE_PLUS;
        }
        return DPI_PHONE;
    }
    
    if (isPad())
    {
        if (isPadMini())
        {
            return DPI_PAD_MINI;
        }
        if (isPadMiniRetina())
        {
            return DPI_PAD_MINI_RETINA;
        }
        if ([[UIScreen mainScreen] scale] > 1)
        {
            return DPI_PAD_RETINA;
        }
        return DPI_PAD;
    }
    return 0;
}

float scaledDpi(void)
{
    return (float)(dpi() / [UIScreen mainScreen].scale);
}
