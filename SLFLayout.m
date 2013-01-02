//
//  SLFLayout.m
//  Autolayout-box
//
//  Created by iain on 21/12/2012.
//  Copyright (c) 2012 iain. All rights reserved.
//

#import "SLFLayout.h"

@implementation SLFLayout {
    NSArray *_constraints;
    NSMapTable *_widthConstraints;
    NSLayoutConstraint *_widthConstraint;
}

@synthesize horizontal = _horizontal;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    //[self setWantsLayer:YES];
    _horizontal = YES;
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    _horizontal = YES;
    return self;
}

/*
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor purpleColor] set];
    NSRectFill([self bounds]);
}
*/
#pragma mark - Constraints

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (NSString *)visualFormatOrientationWithString:(NSString *)visualFormat
                                       inverted:(BOOL)inverted
{
    char orientation;
    
    if (inverted) {
        orientation = [self isHorizontal] ? 'V':'H';
    } else {
        orientation = [self isHorizontal] ? 'H':'V';
    }
    return [NSString stringWithFormat:@"%c:%@", orientation, visualFormat];
}

- (void)updateConstraints
{
    [super updateConstraints];

    if (_constraints == nil) {
        NSMutableArray *constraints = [NSMutableArray array];
        NSMutableDictionary *viewsDict = [NSMutableDictionary dictionary];
        
        NSView *previousView = nil;
        NSString *vf;
        for (NSView *currentView in [self subviews]) {
            viewsDict[@"currentView"] = currentView;
            
            if (previousView == nil) {
                vf = [self visualFormatOrientationWithString:@"|[currentView]" inverted:NO];
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:viewsDict]];
            } else {
                viewsDict[@"previousView"] = previousView;
    
                vf = [self visualFormatOrientationWithString:@"[previousView]-[currentView]" inverted:NO];
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:viewsDict]];
            }
            
            vf = [self visualFormatOrientationWithString:@"|[currentView]|" inverted:YES];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:viewsDict]];
            previousView = currentView;
        }
        
        if ([[self subviews] count] > 0) {
            vf = [self visualFormatOrientationWithString:@"[currentView]|" inverted:NO];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:viewsDict]];
        }
        
        [self setUpdateConstraints:constraints];
    }
}

- (void)setUpdateConstraints:(NSArray *)newConstraints
{
    if (newConstraints != _constraints) {
        if (_constraints) {
            [self removeConstraints:_constraints];
        }
        _constraints = newConstraints;
        
        if (_constraints) {
            [self addConstraints:_constraints];
        } else {
            [self setNeedsUpdateConstraints:YES];
        }
    }
}

#pragma mark - Subviews

- (void)didAddSubview:(NSView *)subview
{
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setUpdateConstraints:nil];

    [super didAddSubview:subview];
}

- (void)willRemoveSubview:(NSView *)subview
{   
    [super willRemoveSubview:subview];
    [self setUpdateConstraints:nil];
}

#pragma mark - Property accessors

- (void)setHorizontal:(BOOL)horizontal
{
    if (_horizontal == horizontal) {
        return;
    }
    
    _horizontal = horizontal;
    
    // Invalidate the constraints
    [self setUpdateConstraints:nil];
}

- (BOOL)isHorizontal
{
    return _horizontal;
}

#pragma mark - Debug
- (void)dumpConstraints
{
    NSLog(@"Dump Constraints\n%@", _constraints);
    [[self window] visualizeConstraints:_constraints];
}
@end
