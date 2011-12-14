//
//  CycParameterXYViewController.m
//  FilterUIViewTest
//
//  Created by Iain Holmes on 09/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "CycParameterXYViewController.h"

@implementation CycParameterXYViewController
@synthesize nameLabel;
@synthesize valueX;
@synthesize valueY;

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
    return [self initWithNibName:@"CycParameterXYViewController" bundle:nil];
}

- (NSView *)view
{
    NSView *view = [super view];
    
    [self bind:@"valueX"
      toObject:view
   withKeyPath:@"xyView.valueX"
       options:nil];
    [self bind:@"valueY"
      toObject:view
   withKeyPath:@"xyView.valueY"
       options:nil];
    
    return view;
}

- (void)setAttributes:(NSDictionary *)attrs
{
    NSString *paramName = [attrs objectForKey:@"CIAttributeDisplayName"];
    [self setName:paramName];
}
@end
