//
//  SLFHorizontalLayout.m
//  Cyclorama
//
//  Created by iain on 29/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFHorizontalLayout.h"

@interface SLFHorizontalLayoutChild : NSObject

@property (readwrite) SLFHorizontalLayoutOptions options;
@property (readwrite, strong) NSView *child;
@property (readwrite) BOOL needsResize;
@property (readwrite) NSRect frame;

- (id)initWithView:(NSView *)view options:(SLFHorizontalLayoutOptions)options;
@end

@implementation SLFHorizontalLayout {
    BOOL _ignoreResizes;
    NSMutableArray *_children;
    NSUInteger _resizableChildren;
    CGFloat _fixedWidth;
}

#define DEFAULT_CONTAINER_SPACING 4.0
#define DEFAULT_CHILD_SPACING 4.0

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    _containerSpacing = DEFAULT_CONTAINER_SPACING;
    _childSpacing = DEFAULT_CHILD_SPACING;
    _ignoreResizes = NO;
    _children = [[NSMutableArray alloc] init];
    
    _debugDrawChildLayout = NO;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    _containerSpacing = DEFAULT_CONTAINER_SPACING;
    _childSpacing = DEFAULT_CHILD_SPACING;
    _children = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)layoutChildrenWithAnimation:(BOOL)animate
{
    NSRect bounds = [self bounds];
    NSRect childArea = NSInsetRect(bounds, 0.0, 0.0);
    CGFloat allowedWidth = childArea.size.width - (_childSpacing * ([_children count] - 1));
    CGFloat childWidth;
    
    allowedWidth -= _fixedWidth;
    
    childWidth = allowedWidth / _resizableChildren;
    
    NSRect childFrame = childArea;
    
    // Look for variable width children and distribute with allowedWidth between them
    for (SLFHorizontalLayoutChild *child in _children) {
        if ([child options] & SLFHorizontalLayoutFixedWidth) {
            childFrame.size.width = [[child child] bounds].size.width;
        } else {
            childFrame.size.width = childWidth;
        }
        
        if (animate) {
            [[[child child] animator] setFrame:childFrame];
        } else {
            [[child child] setFrame:childFrame];
        }
        childFrame.origin.x += childFrame.size.width + _childSpacing;
    }
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    [super resizeWithOldSuperviewSize:oldSize];
    [self layoutChildrenWithAnimation:NO];
}

#pragma mark - Children

- (SLFHorizontalLayoutChild *)findChildForView:(NSView *)view
{
    for (SLFHorizontalLayoutChild *child in _children) {
        if ([child child] == view) {
            return child;
        }
    }
    
    return nil;
}

- (void)addChild:(SLFBox *)childView
     withOptions:(SLFHorizontalLayoutOptions)options
{
    SLFHorizontalLayoutChild *child = [[SLFHorizontalLayoutChild alloc] initWithView:childView
                                                                             options:options];
    
    if (options & SLFHorizontalLayoutFixedWidth) {
        _fixedWidth += [childView frame].size.width;
    } else {
        _resizableChildren++;
    }
    
    [childView setDelegate:self];
    
    [_children addObject:child];
    
    [self addSubview:childView];
    [self layoutChildrenWithAnimation:NO];
}

- (void)removeChild:(NSView *)child
{
    
    /*
    [_children removeObject:child];
    [self layoutChildren];
     */
}

#pragma mark - SLFBox delegate

- (BOOL)box:(SLFBox *)box willCloseToRect:(NSRect)newRect
{
    // Recalculate the width allocated to the fixed width children
    _fixedWidth = 0.0;
    for (SLFHorizontalLayoutChild *child in _children) {
        if ([child options] & SLFHorizontalLayoutFixedWidth) {
            if ([child child] == box) {
                _fixedWidth += newRect.size.width;
                [child setFrame:newRect];
            } else {
                _fixedWidth += [[child child] frame].size.width;
            }
        }
    }

    [self layoutChildrenWithAnimation:YES];

    return YES;
}

- (BOOL)box:(SLFBox *)box willOpenToRect:(NSRect)newRect
{
    // Recalculate the width allocated to the fixed width children
    _fixedWidth = 0.0;
    for (SLFHorizontalLayoutChild *child in _children) {
        if ([child options] & SLFHorizontalLayoutFixedWidth) {
            if ([child child] == box) {
                _fixedWidth += newRect.size.width;
                [child setFrame:newRect];
            } else {
                _fixedWidth += [[child child] frame].size.width;
            }
        }
    }
    
    [self layoutChildrenWithAnimation:YES];

    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_debugDrawChildLayout) {
        [[NSColor blackColor] set];
        
        for (SLFHorizontalLayoutChild *child in _children) {
            NSView *view = [child child];
            NSBezierPath *path = [NSBezierPath bezierPathWithRect:[view frame]];
            
            [path stroke];
        }
    }
}
@end

#pragma mark - SLFHorizontalLayoutChild

@implementation SLFHorizontalLayoutChild

- (id)initWithView:(NSView *)view options:(SLFHorizontalLayoutOptions)options
{
    self = [super init];
    
    _needsResize = YES;
    _child = view;
    _frame = [view frame];
    _options = options;
    
    return self;
}
@end