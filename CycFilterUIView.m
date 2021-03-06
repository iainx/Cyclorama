//
//  CycFilterUIView.m
//  FilterUIViewTest
//
//  Created by Iain Holmes on 01/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "ActorFilter.h"
#import "FilterParameter.h"
#import "CycFilterUIView.h"
#import "CycParameterColourViewController.h"
#import "CycParameterLinearViewController.h"
#import "CycParameterXYViewController.h"

@implementation CycFilterUIView {
    NSMutableArray *_viewControllers;
    double _videoWidth;
    double _videoHeight;
}

@synthesize filter = _filter;

- (id)initWithFrame:(NSRect)frameRect 
          forFilter:(ActorFilter *)filter
     forScreenWidth:(double)_screenWidth
       screenHeight:(double)_screenHeight
           xyParams:(NSArray *)xyParams
       linearParams:(NSArray *)linearParams
{
    self = [super initWithFrame:frameRect];
    
    _videoWidth = _screenWidth;
    _videoHeight = _screenHeight;
    
    _filter = filter;
    _viewControllers = [[NSMutableArray alloc] initWithCapacity:[xyParams count] + [linearParams count]];
    
    double y = 10.0;
    double x = 10.0;

    for (FilterParameter *fp in xyParams) {
        NSRect paramFrame = NSMakeRect(x, y, 0.0, 0.0);
        NSView *attrView;
        
        CycParameterViewController *attrController = [self viewControllerForParameter:fp
                                                                              inFrame:paramFrame];
        
        attrView = [attrController view];
        [attrView setFrameOrigin:paramFrame.origin];
        [self addSubview:attrView];
        
        [_viewControllers addObject:attrController];
        y += [attrView frame].size.height;
        y += 10.0;
    }
    
    if ([xyParams count] > 0) {
        x += 248.0 + 10.0;
    }
    
    y = 10.0;

    for (FilterParameter *fp in linearParams) {
        NSRect paramFrame = NSMakeRect(x, y, 0.0, 0.0);
        NSView *attrView;
        
        CycParameterViewController *attrController = [self viewControllerForParameter:fp
                                                                              inFrame:paramFrame];
        
        attrView = [attrController view];
        [attrView setFrameOrigin:paramFrame.origin];
        [self addSubview:attrView];
        
        [_viewControllers addObject:attrController];
        
        y += [attrView frame].size.height;
        y += 10.0;
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    if (!(self = [self initWithFrame:frame
                           forFilter:nil
                      forScreenWidth:100.0
                        screenHeight:100.0
                            xyParams:nil
                        linearParams:nil])) return nil;
    return self;
}

- (id)initWithFilter:(ActorFilter *)filter
      forScreenWidth:(double)_screenWidth
        screenHeight:(double)_screenHeight
{
    NSRect frame = NSZeroRect;
    NSDictionary *params = [filter parameters];
    
    NSMutableArray *xyParams = [[NSMutableArray alloc] init];
    NSMutableArray *linearParams = [[NSMutableArray alloc] init];
    
    // We sort the parameters into columns based on their sizes
    for (FilterParameter *fp in [params allValues]) {
        NSString *attrClass = [fp className];
        
        if ([attrClass isEqualToString:@"CIVector"]) {
            NSLog(@"Adding CIVector");
            [xyParams addObject:fp];
        } else if ([attrClass isEqualToString:@"NSNumber"] ||
                   [attrClass isEqualToString:@"CIColor"]) {
            [linearParams addObject:fp];
        } else {
            NSLog(@"Unknown class: %@ - %@", attrClass, [fp name]);
        }
    }
    
    double xyHeight;
    double linearHeight;
    
    if ([xyParams count] > 0) {
        xyHeight = [xyParams count] * 130.0 + (([xyParams count] - 1) * 10);
    } else {
        xyHeight = 0;
    }
    
    if ([linearParams count] > 0) {
        linearHeight = [linearParams count] * 28 + (([linearParams count] - 1) * 10);
    } else {
        linearHeight = 0.0;
    }

    frame.size.height = MAX(xyHeight, linearHeight) + 20.0;
    frame.size.width = 800;

    NSLog(@"Height is %f", frame.size.height);
    
    if (!(self = [self initWithFrame:frame 
                           forFilter:filter
                      forScreenWidth:_screenWidth
                        screenHeight:_screenHeight
                            xyParams:xyParams
                        linearParams:linearParams])) return nil;

    return self;
}

- (void)dealloc
{
    for (CycParameterViewController *cvc in _viewControllers) {
        [cvc removeObserver:self forKeyPath:@"paramValue"];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (BOOL)isFlipped
{
    return YES;
}

#pragma mark - Attribute view methods

static void *CycFilterUIViewObservationContext = (void *)@"CycFilterUIViewObservationContext";
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    CycParameterViewController *controller = (CycParameterViewController *)object;
    
    if (context == &CycFilterUIViewObservationContext) {
        FilterParameter *param = [controller parameter];
        [param setValue:change[@"new"]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (CycParameterViewController *)viewControllerForParameter:(FilterParameter *)fp
                                                   inFrame:(NSRect)frame
{
    CycParameterViewController *viewController;
    CycParameterXYViewController *xy = nil;
    NSString *attrClass;
    
    attrClass = [fp className];
    if ([attrClass isEqualToString:@"NSNumber"]) {
        viewController = [[CycParameterLinearViewController alloc] init];
    } else if ([attrClass isEqualToString:@"CIVector"]) {
        xy = [[CycParameterXYViewController alloc] init];
        
        viewController = (CycParameterViewController *)xy;
    } else if ([attrClass isEqualToString:@"CIColor"]){
        viewController = [[CycParameterColourViewController alloc] init];
    } else {
        NSLog(@"Unknown attrType: %@", attrClass);
        return nil;
    }
    
    [viewController setParamName:[fp name]];
    [viewController setParameter:fp];
    
    if (xy) {
        NSLog(@"xy size: %fx%f", _videoWidth, _videoHeight);
        [xy setMaxX:_videoWidth];
        [xy setMaxY:_videoHeight];
    }

    // Add the observer after we've set the attributes and the values
    [viewController addObserver:self
                     forKeyPath:@"paramValue"
                        options:NSKeyValueObservingOptionNew
                        context:&CycFilterUIViewObservationContext];
    return viewController;
}
    
@end
