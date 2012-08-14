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
#import "ActorFilter.h"
#import "FilterParameter.h"

@implementation CycParameterLinearViewController
@synthesize name;
@synthesize paramValue;
@synthesize minParamValue;
@synthesize maxParamValue;

@synthesize nameLabel;
@synthesize valueSlider;

- (id)init
{
    return [super initWithNibName:@"CycParameterLinearViewController" bundle:nil];
}

- (void)setParameter:(FilterParameter *)param
{
    [self setName:[param displayName]];
    
    NSNumber *minValue = [param minValue];
    NSLog(@"Min value: %f", [minValue doubleValue]);
    [self setMinParamValue:[minValue doubleValue]];
    
    NSNumber *maxValue = [param maxValue];
    [self setMaxParamValue:[maxValue doubleValue]];
    
    NSLog(@"Looking for %@", [self paramName]);
    NSNumber *value = [param value];
    NSLog(@"Setting value to %p: %f", value, [value doubleValue]);
    [self setParamValue:[value doubleValue]];
    
    [super setParameter:param];
}

@end
