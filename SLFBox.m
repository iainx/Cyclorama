//
//  SLFBOX.m
//  Cyclorama
//
//  Created by iain on 15/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFBox.h"

@implementation SLFBox

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hasToolbar = YES;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hasToolbar = YES;
    }
    
    return self;
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
        
    NSColor *boxBGColour = [NSColor colorWithCalibratedRed:0.16 green:0.16 blue:0.16 alpha:1.0];
    
    [boxBGColour setFill];
    [roundedPath fill];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [[NSColor blackColor] setStroke];
    [roundedPath setLineWidth:1.0];
    [roundedPath stroke];
    
    [NSGraphicsContext saveGraphicsState];
    
    [roundedPath setClip];
    
    [self drawTitlebarInRect:dirtyRect];
    
    if ([self hasToolbar]) {
        [self drawToolbarInRect:dirtyRect];
    }
    [NSGraphicsContext restoreGraphicsState];
}

#define SLF_BOX_TITLEBAR_HEIGHT 22.0

- (void)drawTitlebarInRect:(NSRect)dirtyRect
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
    
    NSColor *endColour = [NSColor colorWithCalibratedRed:0.242 green:0.242 blue:0.242 alpha:1.0];
    NSColor *startColour = [NSColor colorWithCalibratedRed:0.117 green:0.117 blue:0.117 alpha:1.0];
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:startColour, 0.5, endColour, 1.0, nil];

    [gradient drawInRect:titlebarRect angle:90.0];
    
    NSRect titleRect = NSInsetRect(titlebarRect, 10.0, 4.0);
    NSString *title = [self title];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor whiteColor] };
    
    [title drawInRect:titleRect withAttributes:attributes];
    
    // Draw the divider line
    [[NSColor blackColor] setFill];
    NSRectFill(NSMakeRect(0, bounds.size.height - SLF_BOX_TITLEBAR_HEIGHT, bounds.size.width, 1.0));
    
    [NSGraphicsContext restoreGraphicsState];
}

#define SLF_BOX_TOOLBAR_HEIGHT 25.0

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
    
    NSColor *endColour = [NSColor colorWithCalibratedRed:0.195 green:0.195 blue:0.195 alpha:1.0];
    NSColor *startColour = [NSColor colorWithCalibratedRed:0.14 green:0.14 blue:0.14 alpha:1.0];
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:startColour, 0.0, endColour, 1.0, nil];

    // Reduce the toolbar to draw at 0 -> 23 (24 high)
    toolbarRect.size.height -= 2;
    [gradient drawInRect:toolbarRect angle:90.0];
    
    [[NSColor blackColor] setFill];
    NSRectFill(NSMakeRect(0, SLF_BOX_TOOLBAR_HEIGHT, bounds.size.width, 1.0));
    
    [[NSColor colorWithCalibratedRed:0.261 green:0.261 blue:0.261 alpha:1.0] setFill];
    NSRectFill(NSMakeRect(0, SLF_BOX_TOOLBAR_HEIGHT - 1, bounds.size.width, 1.0));
    
    [NSGraphicsContext restoreGraphicsState];
}
@end
