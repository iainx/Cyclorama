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
#import "ActorFilter.h"
#import "FilterParameter.h"

@implementation CycParameterXYViewController
@synthesize nameLabel;
@synthesize paramValue;
@synthesize maxX;
@synthesize maxY;
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

- (void)setParameter:(FilterParameter *)param
           forFilter:(ActorFilter *)_filter
{
    NSString *paramName = [param displayName];
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

- (void)setMaxX:(double)_maxX
{
    if (maxX == _maxX) {
        return;
    }
    
    maxX = _maxX;
    [xyView setMaxX:maxX];
}

- (double)maxX
{
    return maxX;
}

- (void)setMaxY:(double)_maxY
{
    if (maxY == _maxY) {
        return;
    }
    
    maxY = _maxY;

    [xyView setMaxY:maxY];
}

- (double)maxY
{
    return maxY;
}

@end
