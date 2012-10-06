//
//  utils.m
//  Flare
//
//  Created by Iain Holmes on 10/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "utils.h"

CGColorRef CGColorCreateFromNSColor (NSColor *c)
{
    CGColorRef retColour;
    
    // Awkward function no longer needed in Mountain Lion
    if (NSAppKitVersionNumber <= NSAppKitVersionNumber10_7_2) {
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        NSColor *deviceColour = [c colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        CGFloat components[4];
    
        [deviceColour getRed:&components[0]
                       green:&components[1]
                        blue:&components[2]
                       alpha:&components[3]];
    
        retColour = CGColorCreate(space, components);
        CGColorSpaceRelease(space);
    } else {
        retColour = [c CGColor];
        CGColorRetain (retColour);
    }
    
    return retColour;
}