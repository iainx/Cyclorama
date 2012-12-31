//
//  SLFBoxToolbar.m
//  Cyclorama
//
//  Created by iain on 31/12/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFBoxToolbar.h"

@implementation SLFBoxToolbar {
    NSMutableArray *_startToolbarItems;
    NSMutableArray *_endToolbarItems;
    
    NSArray *_constraints;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    _startToolbarItems = [NSMutableArray array];
    _endToolbarItems = [NSMutableArray array];
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}
/*
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor yellowColor] setFill];
    NSRectFill([self bounds]);
}
*/
#pragma mark - Constraints

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(NSViewNoInstrinsicMetric, 23.0);
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if ([_startToolbarItems count] == 0 && [_endToolbarItems count] == 0) {
        return;
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    NSView *previousView = nil;
    NSMutableDictionary *viewsDict = [NSMutableDictionary dictionary];
    
    for (NSView *toolbarView in _startToolbarItems) {
        viewsDict[@"view"] = toolbarView;
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[view]-3-|"
                                                                                 options:NSLayoutAttributeCenterY
                                                                                 metrics:nil
                                                                                   views:viewsDict]];
        if (previousView == nil) {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[view]"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:viewsDict]];
        } else {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[previousView]-8-[view(==previousView)]"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:viewsDict]];
        }
        
        previousView = toolbarView;
        viewsDict[@"previousView"] = previousView;
    }
    
    BOOL initialItem = YES;
    
    for (NSView *toolbarView in _endToolbarItems) {
        viewsDict[@"view"] = toolbarView;
        if (previousView) {
            viewsDict[@"previousView"] = previousView;
        }
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[view]-3-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDict]];
        if (initialItem) {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[previousView]-(>=8)-[view(==previousView)]"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:viewsDict]];
            initialItem = NO;
        } else {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[previousView]-8-[view(==previousView)]"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:viewsDict]];
        }
        
        previousView = toolbarView;
    }
    
    if (initialItem) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[view]-(>=4)-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDict]];
    } else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[view]-4-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDict]];
    }
    
    [self setUpdateConstraints:constraints];
}

- (void)setUpdateConstraints:(NSArray *)constraints
{
    if (constraints != _constraints) {
        if (_constraints) {
            [self removeConstraints:_constraints];
        }
        _constraints = constraints;
        
        if (_constraints) {
            [self addConstraints:_constraints];
        } else {
            [self setNeedsUpdateConstraints:YES];
        }
    }
}

#pragma mark - Toolbar items

- (void)addToolbarItem:(NSView *)view
           withOptions:(SLFToolbarItemLayoutOptions)options
{
    if (options == SLFToolbarItemLayoutNone) {
        [_startToolbarItems addObject:view];
    } else {
        [_endToolbarItems addObject:view];
    }
    
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:view];
    
    // Redo the constraints
    [self setUpdateConstraints:nil];
}
@end
