//
//  CycFilterColourViewController.m
//  Cyclorama
//
//  Created by iain on 14/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "CycParameterColourViewController.h"
#import "FilterParameter.h"

@interface CycParameterColourViewController ()

@end

@implementation CycParameterColourViewController

- (id)init
{
    self = [super initWithNibName:@"CycParameterColourViewController" bundle:nil];
    return self;
}

- (void)setParameter:(FilterParameter *)param
{
    [self setName:[param displayName]];

    CIColor *ci = (CIColor *)[param value];
    
    NSLog(@"CIColor is %@ %@", ci, [param description]);
    [self setParamValue:[NSColor colorWithCIColor:ci]];
    
    [super setParameter:param];
}

@end
