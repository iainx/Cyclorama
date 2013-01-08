//
//  SLFBOX.m
//  Cyclorama
//
//  Created by iain on 15/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SLFBox.h"
#import "SLFBoxToolbar.h"
#import "SLFCloseButtonCell.h"
#import "SLFToolbarButton.h"
#import "NSBezierPath+MCAdditions.h"

@implementation SLFBox {
    NSButton *_closeButton;
    NSSize _oldFrameSize;

    NSArray *_viewConstraints;
    NSLayoutConstraint *_widthConstraint;
        
    SLFBoxToolbar *_toolbarView;
}

@synthesize hasToolbar = _hasToolbar;

#define SLF_BOX_TITLEBAR_HEIGHT 22.0
#define SLF_BOX_TOOLBAR_HEIGHT 25.0
#define SLF_BOX_TOOLBAR_BUTTON_HEIGHT 22.0
#define SLF_BOX_TOOLBAR_Y_OFFSET 2.0
#define SLF_BOX_TOOLBAR_X_OFFSET 4.0
#define CLOSE_BUTTON_SIZE (SLF_BOX_TITLEBAR_HEIGHT - 4.0)
#define TOOLBAR_BUTTON_GAP 2.0

- (void)doSLFBoxInit
{
    _hasToolbar = YES;
    _hasCloseButton = NO;
    _closed = NO;
    
    [self addToolbar];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doSLFBoxInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doSLFBoxInit];
    }
    
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect frame = NSInsetRect([self bounds], 2,2);
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:1.0];
    [shadow setShadowColor:[NSColor whiteColor]];
    [shadow setShadowOffset:NSMakeSize(0, -1)];
    
    NSBezierPath *roundedPath = [NSBezierPath bezierPathWithRoundedRect:frame
                                                                xRadius:4.0
                                                                yRadius:4.0];

    [NSGraphicsContext saveGraphicsState];
    [shadow set];

    NSColor *boxBGColour;
    
    boxBGColour = [NSColor colorWithCalibratedWhite:0.16 alpha:1.0];
/*
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"linen-tile"
                                                             ofType:@"png"
                                                        inDirectory:@"Resources/Images"];
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
        
        boxBGColour = [NSColor colorWithPatternImage:image];
*/
    
    [boxBGColour setFill];
    [roundedPath fill];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [[NSColor blackColor] setStroke];
    [roundedPath setLineWidth:1.0];
    [roundedPath stroke];
    
    [NSGraphicsContext saveGraphicsState];
    
    [roundedPath setClip];
    
    [self drawTopTitlebarInRect:dirtyRect];
    
    if ([self hasToolbar]) {
        [self drawToolbarInRect:dirtyRect];
    }
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawTopTitlebarInRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    NSRect titlebarRect = bounds;
    NSRect intersection;
    
    titlebarRect.size.height = SLF_BOX_TITLEBAR_HEIGHT;
    titlebarRect.origin.y = bounds.size.height - SLF_BOX_TITLEBAR_HEIGHT;
    
    intersection = NSIntersectionRect(dirtyRect, titlebarRect);
    if (NSIsEmptyRect(intersection)) {
        return;
    }
    
    [NSGraphicsContext saveGraphicsState];
    
    [NSBezierPath clipRect:intersection];
    
    NSColor *endColour = [NSColor colorWithCalibratedWhite:0.242 alpha:1.0];
    NSColor *startColour = [NSColor colorWithCalibratedWhite:0.117 alpha:1.0];
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:startColour, 0.5, endColour, 1.0, nil];

    [gradient drawInRect:titlebarRect angle:90.0];
    
    float titleHorizontalInset;
    if ([self hasCloseButton]) {
        titleHorizontalInset = 26.0;
    } else {
        titleHorizontalInset = 10.0;
    }
    NSRect titleRect = NSInsetRect(titlebarRect, titleHorizontalInset, 4.0);
    NSString *title = [self title];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor whiteColor] };
    
    [NSGraphicsContext saveGraphicsState];
    
    [title drawInRect:titleRect withAttributes:attributes];
    [NSGraphicsContext restoreGraphicsState];
    
    // Draw the divider line
    [[NSColor blackColor] setFill];
    NSRectFill(NSMakeRect(0, titlebarRect.origin.y, bounds.size.width, 1.0));
    
    [NSGraphicsContext restoreGraphicsState];
    
    // Outside the clipping
    
    [NSGraphicsContext saveGraphicsState];
    if ([self isClosed]) {
        NSAffineTransform *tr = [NSAffineTransform transform];
        float dx, dy;
        
        titleRect = NSMakeRect(6.0, 4.0, bounds.size.height - 26.0, 14.0);
        dx = NSMidX(titleRect);
        dy = NSMidY(titleRect);

        [tr translateXBy:dy yBy:dx];
        [tr rotateByDegrees:90.0];
        [tr translateXBy:-dx yBy:-dy];
        [tr concat];
        
        attributes = @{ NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:0.34 alpha:1.0] };
        [title drawInRect:titleRect withAttributes:attributes];
    }

    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawToolbarInRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    NSRect toolbarRect = bounds;
    NSRect intersection;
    
    // The toolbar is from 0 -> 23 (24 high), the white line is at 24 and the black line is 25.
    // Meaning that the rectangle we need to clip against is 0 -> 25 (26 high)
    toolbarRect.size.height = SLF_BOX_TOOLBAR_HEIGHT + 1;

    intersection = NSIntersectionRect(dirtyRect, toolbarRect);
    if (NSIsEmptyRect(intersection)) {
        return;
    }
    
    [NSGraphicsContext saveGraphicsState];
    
    [NSBezierPath clipRect:intersection];
    
    NSColor *endColour = [NSColor colorWithCalibratedWhite:0.195 alpha:1.0];
    NSColor *startColour = [NSColor colorWithCalibratedWhite:0.14 alpha:1.0];
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:startColour, 0.0, endColour, 1.0, nil];

    // Reduce the toolbar to draw at 0 -> 23 (24 high)
    toolbarRect.size.height -= 2;
    [gradient drawInRect:toolbarRect angle:90.0];
    
    [[NSColor blackColor] setFill];
    NSRectFill(NSMakeRect(0, SLF_BOX_TOOLBAR_HEIGHT, bounds.size.width, 1.0));
    
    [[NSColor colorWithCalibratedWhite:0.261 alpha:1.0] setFill];
    NSRectFill(NSMakeRect(0, SLF_BOX_TOOLBAR_HEIGHT - 1, bounds.size.width, 1.0));
    
    [NSGraphicsContext restoreGraphicsState];
}

#pragma mark - Close button

- (void)addCloseButton
{
    _closeButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    
    SLFCloseButtonCell *cell = [[SLFCloseButtonCell alloc] init];
    [cell setType:SLFButtonCellTypeClose];
    
    [_closeButton setCell:cell];
    [_closeButton setButtonType:NSMomentaryChangeButton];
    [_closeButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
    [_closeButton setTarget:self];
    [_closeButton setAction:@selector(closeAction:)];
    [_closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_closeButton];
}

- (void)closeAction:(id)sender
{
    if ([self isClosed]) {
        [self setClosed:NO];
        [_contentView setHidden:NO];
        [(SLFCloseButtonCell *)[_closeButton cell] setType:SLFButtonCellTypeClose];
        [_closeButton setNeedsDisplay];

        [self.superview removeConstraint:_widthConstraint];
        _widthConstraint = nil;
    } else {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:22.0];
        [self.superview addConstraint:widthConstraint];
        _widthConstraint = widthConstraint;

        // Hide the contents
        [_contentView setHidden:YES];

        [self setClosed:YES];
        [(SLFCloseButtonCell *)[_closeButton cell] setType:SLFButtonCellTypeOpen];
        [_closeButton setNeedsDisplay];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Accessors

- (void)setHasToolbar:(BOOL)hasToolbar
{
    if (_hasToolbar == hasToolbar) {
        return;
    }
    
    _hasToolbar = hasToolbar;
    if (_hasToolbar) {
        [self addToolbar];
    } else {
        [self removeToolbar];
    }
    
    [self setNeedsDisplay:YES];
}

- (BOOL)hasToolbar
{
    return _hasToolbar;
}

- (void)setHasCloseButton:(BOOL)hasCloseButton
{
    if (_hasCloseButton == hasCloseButton) {
        return;
    }
    
    if (_hasCloseButton) {
        [_closeButton removeFromSuperview];
        _closeButton = nil;
    } else {
        [self addCloseButton];
    }
    
    _hasCloseButton = hasCloseButton;
}

#pragma mark - Constraints

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (NSSize)intrinsicContentSize
{
    // By default the box has no intrinsic size
    return NSMakeSize(NSViewNoInstrinsicMetric, NSViewNoInstrinsicMetric);
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    float toolbarHeight = 3.0;
    if ([self hasToolbar]) {
        toolbarHeight = SLF_BOX_TOOLBAR_HEIGHT + 1.0;
    }
    
    NSMutableDictionary *viewDict = [NSMutableDictionary dictionaryWithObject:_contentView
                                                                       forKey:@"childView"];
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[childView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewDict]];
    if ([self hasToolbar]) {
        [viewDict setObject:_toolbarView forKey:@"toolbar"];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[childView]-[toolbar]-2-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewDict]];
    } else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[childView]-3-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewDict]];
    }
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[childView]-3-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewDict]];
    
    if ([self hasCloseButton]) {
        NSDictionary *closeViewDict = @{@"button":_closeButton};
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[button(==18)]-(>=4)-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:closeViewDict]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-2-[button(==18)]-(>=2)-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:closeViewDict]];
    }
    
    if ([self hasToolbar]) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-3-[toolbar]-3-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewDict]];
    }
    
    [self setUpdateConstraints:constraints];
}

- (void)setUpdateConstraints:(NSArray *)constraints
{
    if (constraints != _viewConstraints) {
        if (_viewConstraints) {
            [self removeConstraints:_viewConstraints];
        }
        _viewConstraints = constraints;
        
        if (_viewConstraints) {
            [self addConstraints:_viewConstraints];
        } else {
            [self setNeedsUpdateConstraints:YES];
        }
    }
}

#pragma mark - Content view

- (void)setContentView:(NSView *)aView
{
    if (aView == _contentView) {
        return;
    }
    
    if (_contentView) {
        [_contentView removeFromSuperviewWithoutNeedingDisplay];
    }
    
    _contentView = aView;
    [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_contentView];
    
    [self setUpdateConstraints:nil];
}

#pragma mark - Toolbar

- (void)addToolbar
{    
    _toolbarView = [[SLFBoxToolbar alloc] initWithFrame:NSZeroRect];
    [_toolbarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_toolbarView];
    
    [self setUpdateConstraints:nil];
}

- (void)removeToolbar
{
    [_toolbarView removeFromSuperview];
    [self setUpdateConstraints:nil];
}

- (void)addToolbarItem:(NSView *)view
           withOptions:(SLFToolbarItemLayoutOptions)options
{
    if (![self hasToolbar]){
        return;
    }
 
    [_toolbarView addToolbarItem:view
                     withOptions:options];
}

- (void)addToolbarButtonWithLabel:(NSString *)text
                          options:(SLFToolbarItemLayoutOptions)options
                           action:(SEL)action
                           target:(id)target
{
    if (![self hasToolbar]) {
        return;
    }
    
    SLFToolbarButton *button = [[SLFToolbarButton alloc] initWithTitle:text action:action target:target];
    
    [self addToolbarItem:button
             withOptions:options];
}

@end