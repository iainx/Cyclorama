//
//  CycParameterViewController.m
//  FilterUIViewTest
//
//  Created by Iain Holmes on 02/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "CycParameterLinearViewController.h"

@implementation CycParameterLinearViewController
@synthesize name;
@synthesize paramValue;
@synthesize minParamValue;
@synthesize maxParamValue;

@synthesize nameLabel;
@synthesize valueSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)init
{
    return [self initWithNibName:@"CycParameterLinearViewController" bundle:nil];
}

- (void)setAttributes:(NSDictionary *)attrs 
            forFilter:(CIFilter *)_filter
{
    NSString *displayName = [attrs objectForKey:@"CIAttributeDisplayName"];
    [self setName:displayName];
    
    NSNumber *minValue = [attrs objectForKey:@"CIAttributeSliderMin"];
    [self setMinParamValue:[minValue doubleValue]];
    
    NSNumber *maxValue = [attrs objectForKey:@"CIAttributeSliderMax"];
    [self setMaxParamValue:[maxValue doubleValue]];
    
    //NSNumber *defaultValue = [attrs objectForKey:@"CIAttributeDefault"];
    NSLog(@"Looking for %@", [self paramName]);
    NSNumber *value = [_filter valueForKey:[self paramName]];
    NSLog(@"Setting value to %p: %f", value, [value doubleValue]);
    [self setParamValue:[value doubleValue]];
}

@end
