//
//  utils.m
//  Flare
//
//  Created by Iain Holmes on 10/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>

CGColorRef CGColorCreateFromNSColor (NSColor *c)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGColorRef retColour;
    NSColor *deviceColour = [c colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    CGFloat components[4];
    
    [deviceColour getRed:&components[0] 
                   green:&components[1] 
                    blue:&components[2] 
                   alpha:&components[3]];
    
    retColour = CGColorCreate(space, components);
    CGColorSpaceRelease(space);
    
    return retColour;
}