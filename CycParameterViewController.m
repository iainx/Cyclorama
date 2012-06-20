//
//  CycParameterViewController.m
//  FilterUIViewTest
//
//  Created by Iain Holmes on 09/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "CycParameterViewController.h"

@implementation CycParameterViewController
@synthesize name;
@synthesize paramName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setAttributes:(NSDictionary *)attrs 
            forFilter:(CIFilter *)_filter
{
    NSLog(@"Subclass didn't implement setAttributes:forFilter:");
}
@end
