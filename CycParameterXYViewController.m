//
//  CycParameterXYViewController.m
//  FilterUIViewTest
//
//  Created by Iain Holmes on 09/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "CycParameterXYViewController.h"
#import "CycParameterXYView.h"
#import "CycXYView.h"

@implementation CycParameterXYViewController
@synthesize nameLabel;
@synthesize paramValue;
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
    
    xyView = [(CycParameterXYView *)view xyView];
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

    //[xyView setVector:defaultVector];
}

- (void)setValueX:(double)_valueX
{
    if (_valueX == valueX) {
        return;
    }
    
    valueX = _valueX;
    CIVector *vector = [CIVector vectorWithX:valueX Y:valueY];
    [self setParamValue:vector];
}

- (double)valueX
{
    return valueX;
}

- (void)setValueY:(double)_valueY
{
    if (_valueY == valueY) {
        return;
    }
    
    valueY = _valueY;
    CIVector *vector = [CIVector vectorWithX:valueX Y:valueY];
    [self setParamValue:vector];
}

- (double)valueY
{
    return valueY;
}
@end
