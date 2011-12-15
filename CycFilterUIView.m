//
//  CycFilterUIView.m
//  FilterUIViewTest
//
//  Created by Iain Holmes on 01/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
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

- (id)initWithFrame:(NSRect)frameRect forFilter:(CIFilter *)filter
{
    self = [super initWithFrame:frameRect];
    
    _filter = [filter retain];
    
    NSDictionary *attributes = [filter attributes];
    
    double y = 10.0;
    double x = 10.0;

    for (NSString *inputName in xyParams) {
        NSDictionary *attrs = [attributes objectForKey:inputName];
        NSRect paramFrame = NSMakeRect(x, y, 0.0, 0.0);
        NSView *attrView = [self viewForParameterNamed:inputName 
                                        withAttributes:attrs 
                                               inFrame:paramFrame];
        [self addSubview:attrView];
        
        y += [attrView frame].size.height;
        y += 10.0;
    }
    
    if ([xyParams count] > 0) {
        x += 248.0 + 10.0;
    }
    
    y = 10.0;

    for (NSString *inputName in linearParams) {
        NSDictionary *attrs = [attributes objectForKey:inputName];
        NSRect paramFrame = NSMakeRect(x, y, 0.0, 0.0);
        NSView *attrView = [self viewForParameterNamed:inputName 
                                        withAttributes:attrs
                                               inFrame:paramFrame];
        [self addSubview:attrView];
        
        y += [attrView frame].size.height;
        y += 10.0;
    }
    
    // We've finished with these, so we can release them
    [xyParams release];
    xyParams = nil;
    [linearParams release];
    linearParams = nil;
    
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    [self initWithFrame:frame forFilter:nil];
    return self;
}

- (id)initWithFilter:(CIFilter *)filter
{
    NSRect frame = NSZeroRect;
    NSArray *inputKeys = [filter inputKeys];
    NSDictionary *attributes = [filter attributes];
    
    xyParams = [[NSMutableArray alloc] init];
    linearParams = [[NSMutableArray alloc] init];
    
    for (NSString *inputName in inputKeys) {
        if ([inputName isEqualToString:@"inputImage"]) {
            continue;
        }
        
        NSDictionary *attrs = [attributes objectForKey:inputName];
        
        NSString *attrClass = [attrs objectForKey:@"CIAttributeClass"];
        NSLog(@"AttrType: %@", attrClass);
        if ([attrClass isEqualToString:@"CIVector"]) {
            [xyParams addObject:inputName];
        } else if ([attrClass isEqualToString:@"NSNumber"]) {
            [linearParams addObject:inputName];
        } else {
            NSLog(@"Unknown class: %@ - %@", attrClass, inputName);
        }
    }
    
    double xyHeight = [xyParams count] * 130.0 + (([xyParams count] - 1) * 10);
    double linearHeight = [linearParams count] * 28 + (([linearParams count] - 1) * 10);

    frame.size.height = MAX(xyHeight, linearHeight) + 20.0;
    frame.size.width = 800;

    NSLog(@"Height is %f", frame.size.height);
    [self initWithFrame:frame forFilter:filter];

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
        NSLog(@"%@ changed on param %@ - %@", keyPath, [controller paramName], [change description]);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSView *)viewForParameterNamed:(NSString *)pName 
                   withAttributes:(NSDictionary *)attrs 
                          inFrame:(NSRect)frame
{
    CycParameterViewController *viewController;
    NSView *view;
    NSString *attrClass;
    
    attrClass = [attrs objectForKey:@"CIAttributeClass"];
    if ([attrClass isEqualToString:@"NSNumber"]) {
        viewController = [[CycParameterLinearViewController alloc] init];
    } else if ([attrClass isEqualToString:@"CIVector"]) {
        viewController = [[CycParameterXYViewController alloc] init];
    } else {
        NSLog(@"Unknown attrType: %@", attrClass);
        return nil;
    }
    
    [viewController setParamName:pName];
    view = [viewController view];
    [viewController setAttributes:attrs];

    // Add the observer after we've set the attributes and the values
    [viewController addObserver:self
                     forKeyPath:@"paramValue"
                        options:NSKeyValueObservingOptionNew
                        context:&CycFilterUIViewObservationContext];
    [view setFrameOrigin:frame.origin];
    return view;
}

@end
