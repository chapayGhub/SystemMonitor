//
//  AMUtils.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import "AMLog.h"
#import "AMUtils.h"

@interface AMUtils()
@end

@implementation AMUtils

#pragma mark - static public

+ (uint64_t)getSysCtl64WithSpecifier:(char*)specifier
{
    size_t size = -1;
    uint64_t val = 0;
    
    if (!specifier)
    {
        AMWarn(@"%s: specifier == NULL", __PRETTY_FUNCTION__);
        return -1;
    }
    if (strlen(specifier) == 0)
    {
        AMWarn(@"%s: strlen(specifier) == 0", __PRETTY_FUNCTION__);
        return -1;
    }
    
    if (sysctlbyname(specifier, NULL, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname size with specifier '%s' has failed: %s",
               __PRETTY_FUNCTION__, specifier, strerror(errno));
        return -1;
    }
    
    if (size == -1)
    {
        AMWarn(@"%s: sysctlbyname with specifier '%s' returned invalid size",
               __PRETTY_FUNCTION__, specifier);
        return -1;
    }
    
    
    if (sysctlbyname(specifier, &val, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname value with specifier '%s' has failed: %s",
               __PRETTY_FUNCTION__, specifier, strerror(errno));
        return -1;
    }
    
    return val;
}

+ (NSString*)getSysCtlChrWithSpecifier:(char*)specifier
{
    size_t size = -1;
    char *val;
    NSString *result = @"";
    
    if (!specifier)
    {
        AMWarn(@"%s: specifier == NULL", __PRETTY_FUNCTION__);
        return result;
    }
    if (strlen(specifier) == 0)
    {
        AMWarn(@"%s: strlen(specifier) == 0", __PRETTY_FUNCTION__);
        return result;
    }
    
    if (sysctlbyname(specifier, NULL, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname size with specifier '%s' has failed: %s",
               __PRETTY_FUNCTION__, specifier, strerror(errno));
        return result;
    }
    
    if (size == -1)
    {
        AMWarn(@"%s: sysctlbyname with specifier '%s' returned invalid size",
               __PRETTY_FUNCTION__, specifier);
        return result;
    }
    
    val = (char*)malloc(size);
    
    if (sysctlbyname(specifier, val, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname value with specifier '%s' has failed: %s",
               __PRETTY_FUNCTION__, specifier, strerror(errno));
        free(val);
        return result;
    }
    
    result = [NSString stringWithUTF8String:val];
    free(val);
    return result;
}

+ (void*)getSysCtlPtrWithSpecifier:(char*)specifier pointer:(void*)ptr size:(size_t)size
{    
    if (!specifier)
    {
        AMWarn(@"%s: specifier == NULL", __PRETTY_FUNCTION__);
        return nil;
    }
    if (strlen(specifier) == 0)
    {
        AMWarn(@"%s: strlen(specifier) == 0", __PRETTY_FUNCTION__);
        return nil;
    }
    
    if (sysctlbyname(specifier, ptr, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname value with specifier '%s' has failed: %s",
               __PRETTY_FUNCTION__, specifier, strerror(errno));
        return nil;
    }
    
    return ptr;
}

+ (uint64_t)getSysCtlHw:(uint32_t)hwSpecifier
{
    size_t size = 0;
    uint64_t val = -1;
    int mib[2] = { CTL_HW, hwSpecifier };
    
    if (sysctl(mib, 2, NULL, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname size with specifier %u has failed: %s",
               __PRETTY_FUNCTION__, hwSpecifier, strerror(errno));
        return -1;
    }
    
    if (size > sizeof(uint64_t))
    {
        AMWarn(@"%s: sysctlbyname with specifier %u size > sizeof(uint64_t). Expect corrupted data.",
               __PRETTY_FUNCTION__, hwSpecifier);
    }
    
    if (sysctl(mib, 2, &val, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctlbyname size with specifier %u has failed: %s",
               __PRETTY_FUNCTION__, hwSpecifier, strerror(errno));
        return -1;
    }
    
    return val;
}

+ (float)percentageValueFromMax:(float)max min:(float)min percent:(float)percent
{
    assert(max > min);
    return min + ((max - min) / 100 * percent);
}

+ (float)valuePercentFrom:(float)from to:(float)to value:(float)value
{
    assert(from < to);
    
    float phase = from;
    float zeroBasedValue = value - phase;
    return 100 / (to - from) * zeroBasedValue;
}

+ (CGFloat)random
{
#define ARC4RANDOM_MAX  0x100000000
    return (double)arc4random() / ARC4RANDOM_MAX;
#undef ARC4RANDOM_MAX
}

@end
