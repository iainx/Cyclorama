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
#import "CycParameterLinearViewController.h"
#import "CycParameterXYViewController.h"

@interface CycFilterUIView()
- (NSView *)viewForParameterNamed:(NSString *)pName 
                   withAttributes:(NSDictionary *)attrs
                          inFrame:(NSRect)frame;
@end

@implementation CycFilterUIView

@synthesize filter = _filter;

- (id)initWithFrame:(NSRect)frameRect 
          forFilter:(ActorFilter *)filter
     forScreenWidth:(double)_screenWidth
       screenHeight:(double)_screenHeight
{
    self = [super initWithFrame:frameRect];
    
    videoWidth = _screenWidth;
    videoHeight = _screenHeight;
    
    _filter = filter;
    
    double y = 10.0;
    double x = 10.0;

    for (FilterParameter *fp in xyParams) {
        NSRect paramFrame = NSMakeRect(x, y, 0.0, 0.0);
        NSView *attrView = [self viewForParameter:fp
                                          inFrame:paramFrame];
        [self addSubview:attrView];
        
        y += [attrView frame].size.height;
        y += 10.0;
    }
    
    if ([xyParams count] > 0) {
        x += 248.0 + 10.0;
    }
    
    y = 10.0;

    for (FilterParameter *fp in linearParams) {
        NSRect paramFrame = NSMakeRect(x, y, 0.0, 0.0);
        NSView *attrView = [self viewForParameter:fp
                                          inFrame:paramFrame];
        [self addSubview:attrView];
        
        y += [attrView frame].size.height;
        y += 10.0;
    }
    
    // We've finished with these, so we can release them
    xyParams = nil;
    linearParams = nil;
    
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    if (!(self = [self initWithFrame:frame forFilter:nil forScreenWidth:100.0 screenHeight:100.0])) return nil;
    return self;
}

- (id)initWithFilter:(ActorFilter *)filter
      forScreenWidth:(double)_screenWidth
        screenHeight:(double)_screenHeight
{
    NSRect frame = NSZeroRect;
    NSDictionary *params = [filter parameters];
    /*
    NSArray *inputKeys = [filter inputKeys];
    NSDictionary *attributes = [filter attributes];
    */
    
    xyParams = [[NSMutableArray alloc] init];
    linearParams = [[NSMutableArray alloc] init];
    
    NSLog(@"Params is %@", [params description]);
    for (FilterParameter *fp in [params allValues]) {
        NSString *attrClass = [fp className];
        
        if ([attrClass isEqualToString:@"CIVector"]) {
            NSLog(@"Adding CIVector");
            [xyParams addObject:fp];
        } else if ([attrClass isEqualToString:@"NSNumber"]) {
            NSLog(@"Adding NSNumber");
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
           screenHeight:_screenHeight])) return nil;

    return self;
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
        [param setValue:[change objectForKey:@"new"]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSView *)viewForParameter:(FilterParameter *)fp
                     inFrame:(NSRect)frame
{
    CycParameterViewController *viewController;
    CycParameterXYViewController *xy = nil;
    NSView *view;
    NSString *attrClass;
    
    attrClass = [fp className];
    if ([attrClass isEqualToString:@"NSNumber"]) {
        viewController = [[CycParameterLinearViewController alloc] init];
    } else if ([attrClass isEqualToString:@"CIVector"]) {
        xy = [[CycParameterXYViewController alloc] init];
        
        viewController = (CycParameterViewController *)xy;
    } else {
        NSLog(@"Unknown attrType: %@", attrClass);
        return nil;
    }
    
    [viewController setParamName:[fp name]];
    view = [viewController view];
    [viewController setParameter:fp];
    
    // if xy is nil these will just return
    [xy setMaxX:videoWidth];
    [xy setMaxY:videoHeight];

    // Add the observer after we've set the attributes and the values
    [viewController addObserver:self
                     forKeyPath:@"paramValue"
                        options:NSKeyValueObservingOptionNew
                        context:&CycFilterUIViewObservationContext];
    [view setFrameOrigin:frame.origin];
    return view;
}
    
@end
