//
//  SLFBOX.m
//  Cyclorama
//
//  Created by iain on 15/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SLFBox.h"
#import "SLFToolbarButton.h"
#import "NSBezierPath+MCAdditions.h"

@interface _SLFCloseButtonCell : NSButtonCell

@property (readwrite) BOOL openButton;

@end

@implementation SLFBox {
    NSButton *_closeButton;
    NSSize _oldFrameSize;
    NSMutableArray *_startToolbarItems;
    NSMutableArray *_endToolbarItems;
}

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
    
    _startToolbarItems = [[NSMutableArray alloc] init];
    _endToolbarItems = [[NSMutableArray alloc] init];
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


- (void)addCloseButton
{
    NSRect bounds = [self bounds];
    
    NSRect closeButtonRect = NSMakeRect(2.0, (bounds.size.height - SLF_BOX_TITLEBAR_HEIGHT),
                                        CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE);

    _closeButton = [[NSButton alloc] initWithFrame:closeButtonRect];
    [_closeButton setCell:[[_SLFCloseButtonCell alloc] init]];
    [_closeButton setButtonType:NSMomentaryChangeButton];
    [_closeButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
    [_closeButton setTarget:self];
    [_closeButton setAction:@selector(closeAction:)];
    
    [self addSubview:_closeButton];
}

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
    if (bounds.size.width == 22 && [_contentView isHidden]) {
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

- (void)closeAction:(id)sender
{
    BOOL shouldContinue = YES;
    
    if ([self isClosed]) {
        NSRect oldFrame = NSMakeRect([self frame].origin.x - (_oldFrameSize.width - 22.0),
                                     [self frame].origin.y,
                                     _oldFrameSize.width, _oldFrameSize.height);

        if ([_delegate respondsToSelector:@selector(box:willOpenToRect:)]) {
            shouldContinue = [_delegate box:self willOpenToRect:oldFrame];
        }
        
        if (shouldContinue == NO) {
            return;
        }
        
        [_contentView setHidden:NO];
        [[self animator] setFrame:oldFrame];
        
        [self setClosed:NO];
        [(_SLFCloseButtonCell *)[_closeButton cell] setOpenButton:NO];
        [_closeButton setNeedsDisplay];
        
        if ([_delegate respondsToSelector:@selector(boxDidOpen:)]) {
            [_delegate boxDidOpen:self];
        }
    } else {
        NSRect newFrame = [self frame];
        _oldFrameSize = newFrame.size;
        
        newFrame.origin.x = newFrame.origin.x + newFrame.size.width - SLF_BOX_TITLEBAR_HEIGHT;
        newFrame.size.width = SLF_BOX_TITLEBAR_HEIGHT;
        
        if ([_delegate respondsToSelector:@selector(box:willCloseToRect:)]) {
            shouldContinue = [_delegate box:self willCloseToRect:newFrame];
        }
        
        if (shouldContinue == NO) {
            return;
        }
        
        [[self animator] setFrame:newFrame];
        
        // Hide the contents
        [[_contentView animator ]setHidden:YES];
        
        [self setClosed:YES];
        [(_SLFCloseButtonCell *)[_closeButton cell] setOpenButton:YES];
        [_closeButton setNeedsDisplay];
        
        if ([_delegate respondsToSelector:@selector(boxDidClose:)]) {
            [_delegate boxDidClose:self];
        }
    }
}

#pragma mark - Accessors

- (void)setChildFrame
{
    NSRect boxBounds = [self bounds];
    NSView *childView = [self contentView];
    CGFloat toolbarHeight;
    
    if (childView == nil) {
        return;
    }
    
    NSRect childFrame;
    NSSize contentMargins = [self contentViewMargins];

    if ([self hasToolbar]) {
        toolbarHeight = SLF_BOX_TITLEBAR_HEIGHT + 4;
    } else {
        toolbarHeight = 3.0;
    }
    
    childFrame = NSMakeRect(3.0 + contentMargins.width, toolbarHeight + contentMargins.height,
                            boxBounds.size.width - (3.0 * 2) - (contentMargins.width * 2),
                            boxBounds.size.height - (toolbarHeight + SLF_BOX_TITLEBAR_HEIGHT + (contentMargins.height * 2)));
    
    [childView setFrame:childFrame];
}

- (void)setContentView:(NSView *)aView
{
    if (aView == _contentView) {
        return;
    }
    
    if (_contentView) {
        [_contentView removeFromSuperviewWithoutNeedingDisplay];
    }
    
    _contentView = aView;
    [self addSubview:_contentView];
    [self setChildFrame];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [self setChildFrame];
    
    // Now reposition the close button
    if ([self hasCloseButton]) {
        NSRect closeButtonRect = NSMakeRect(2.0, ([self bounds].size.height - SLF_BOX_TITLEBAR_HEIGHT),
                                            CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE);
        [_closeButton setFrame:closeButtonRect];
    }
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

- (void)setHasToolbar:(BOOL)hasToolbar
{
    if (_hasToolbar == hasToolbar) {
        return;
    }
    
    _hasToolbar = hasToolbar;
    
    [self setChildFrame];
    [self setNeedsDisplay:YES];
}

#pragma mark - Toolbar Items

- (void)layoutItemInToolbar:(NSView *)item
                withOptions:(SLFToolbarItemLayoutOptions)options
{
    NSView *lastItem;
    CGFloat x, y;
    
    if (options == SLFToolbarItemLayoutNone) {
        lastItem = [_startToolbarItems lastObject];
        
        if (lastItem) {
            NSRect lastViewFrame = [lastItem frame];
            x = NSMaxX(lastViewFrame);
        } else {
            x = 0.0;
        }
        
        [_startToolbarItems addObject:item];
        x += SLF_BOX_TOOLBAR_X_OFFSET;
    } else {
        lastItem = [_endToolbarItems lastObject];
        
        if (lastItem) {
            NSRect lastViewFrame = [lastItem frame];
            x = NSMinX(lastViewFrame);
        } else {
            x = NSMaxX([self bounds]) - SLF_BOX_TOOLBAR_X_OFFSET;
        }
        
        [_endToolbarItems addObject:item];
        x -= (SLF_BOX_TOOLBAR_X_OFFSET + [item bounds].size.width);
        
    }
    
    y = ((SLF_BOX_TITLEBAR_HEIGHT  - [item bounds].size.height) / 2.0) + 2.0;
    [item setFrameOrigin:NSMakePoint(x, y)];
}

- (void)addToolbarItem:(NSView *)view
           withOptions:(SLFToolbarItemLayoutOptions)options
{
    [self layoutItemInToolbar:view withOptions:options];
    [self addSubview:view];
}

- (void)addToolbarButtonWithLabel:(NSString *)text
                          options:(SLFToolbarItemLayoutOptions)options
                           action:(SEL)action
                           target:(id)target
{
    SLFToolbarButton *button = [[SLFToolbarButton alloc] initWithTitle:@"Test" action:action target:target];
    [self addToolbarItem:button
             withOptions:options];
}

@end

#pragma mark - _SLFCloseButtonCell

@implementation _SLFCloseButtonCell

// Code from SNRHUDKit https://github.com/indragiek/SNRHUDKit

#define SNRWindowButtonBorderColor      [NSColor colorWithDeviceWhite:0.040 alpha:1.000]
#define SNRWindowButtonGradientBottomColor  [NSColor colorWithDeviceWhite:0.070 alpha:1.000]
#define SNRWindowButtonGradientTopColor     [NSColor colorWithDeviceWhite:0.220 alpha:1.000]
#define SNRWindowButtonDropShadowColor  [NSColor colorWithDeviceWhite:1.000 alpha:0.100]
#define SNRWindowButtonCrossColor       [NSColor colorWithDeviceWhite:0.450 alpha:1.000]
#define SNRWindowButtonCrossInset       1.f
#define SNRWindowButtonHighlightOverlayColor [NSColor colorWithDeviceWhite:0.000 alpha:0.300]
#define SNRWindowButtonInnerShadowColor [NSColor colorWithDeviceWhite:1.000 alpha:0.100]
#define SNRWindowButtonInnerShadowOffset NSMakeSize(0.f, 0.f)
#define SNRWindowButtonInnerShadowBlurRadius    1.f

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect drawingRect = NSInsetRect(cellFrame, 1.5f, 1.5f);
    drawingRect.origin.y = 0.5f;
    NSRect dropShadowRect = drawingRect;
    dropShadowRect.origin.y += 1.f;
    
    // Draw the drop shadow so that the bottom edge peeks through
    NSBezierPath *dropShadow = [NSBezierPath bezierPathWithOvalInRect:dropShadowRect];
    [SNRWindowButtonDropShadowColor set];
    [dropShadow stroke];

    // Draw the main circle w/ gradient & border on top of it
    NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:drawingRect];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:SNRWindowButtonGradientBottomColor
                                                         endingColor:SNRWindowButtonGradientTopColor];
    [gradient drawInBezierPath:circle angle:270.f];
    [SNRWindowButtonBorderColor set];
    [circle stroke];
    
    // Draw the cross
    NSBezierPath *cross = [NSBezierPath bezierPath];
    
    CGFloat boxDimension = floor(drawingRect.size.width * cos(45.f)) - SNRWindowButtonCrossInset;
    CGFloat origin = round((drawingRect.size.width - boxDimension) / 2.f);
    
    NSRect boxRect = NSMakeRect(1.f + origin, origin, boxDimension, boxDimension);
    
    if ([self openButton]) {
        NSPoint topRight = NSMakePoint(NSMaxX(boxRect), boxRect.origin.y);
        NSPoint bottomRight = NSMakePoint(topRight.x, NSMaxY(boxRect));
        NSPoint midLeft = NSMakePoint(boxRect.origin.x, NSMidY(boxRect));
        
        [cross moveToPoint:bottomRight];
        [cross lineToPoint:midLeft];
        [cross lineToPoint:topRight];
    } else {
        NSPoint bottomLeft = NSMakePoint(boxRect.origin.x, NSMaxY(boxRect));
        NSPoint topRight = NSMakePoint(NSMaxX(boxRect), boxRect.origin.y);
        NSPoint bottomRight = NSMakePoint(topRight.x, bottomLeft.y);
        NSPoint topLeft = NSMakePoint(bottomLeft.x, topRight.y);
        
        [cross moveToPoint:bottomLeft];
        [cross lineToPoint:topRight];
        [cross moveToPoint:bottomRight];
        [cross lineToPoint:topLeft];
    }
    
    [SNRWindowButtonCrossColor set];
    [cross setLineWidth:2.f];
    [cross stroke];

    // Draw the inner shadow
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:SNRWindowButtonInnerShadowColor];
    [shadow setShadowBlurRadius:SNRWindowButtonInnerShadowBlurRadius];
    [shadow setShadowOffset:SNRWindowButtonInnerShadowOffset];
    NSRect shadowRect = drawingRect;
    shadowRect.size.height = origin;
    
    [NSGraphicsContext saveGraphicsState];
    [NSBezierPath clipRect:shadowRect];
    
    [circle fillWithInnerShadow:shadow];
    [NSGraphicsContext restoreGraphicsState];
    if ([self isHighlighted]) {
        [SNRWindowButtonHighlightOverlayColor set];
        [circle fill];
    }
}

@end
