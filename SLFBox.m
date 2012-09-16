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
    
    [self drawTitlebarInRect:[self bounds]];
    
    if ([self hasToolbar]) {
        [self drawToolbarInRect:[self bounds]];
    }
    [NSGraphicsContext restoreGraphicsState];
}

#define SLF_BOX_TITLEBAR_HEIGHT 22.0

- (void)drawTitlebarInRect:(NSRect)frame
{
    NSColor *endColour = [NSColor colorWithCalibratedRed:0.242 green:0.242 blue:0.242 alpha:1.0];
    NSColor *startColour = [NSColor colorWithCalibratedRed:0.117 green:0.117 blue:0.117 alpha:1.0];
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:startColour, 0.5, endColour, 1.0, nil];
    
    NSRect titlebarRect = frame;
    titlebarRect.size.height = SLF_BOX_TITLEBAR_HEIGHT;
    titlebarRect.origin.y = frame.size.height - SLF_BOX_TITLEBAR_HEIGHT;
    
    [gradient drawInRect:titlebarRect angle:90.0];
    
    NSRect titleRect = NSInsetRect(titlebarRect, 10.0, 4.0);
    NSString *title = [self title];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor whiteColor] };
    
    [title drawInRect:titleRect withAttributes:attributes];
    
    // Draw the divider line
    [[NSColor blackColor] setFill];
    NSRectFill(NSMakeRect(0, frame.size.height - SLF_BOX_TITLEBAR_HEIGHT, frame.size.width, 1.0));
}

#define SLF_BOX_TOOLBAR_HEIGHT 25.0

- (void)drawToolbarInRect:(NSRect)frame
{
    NSColor *endColour = [NSColor colorWithCalibratedRed:0.195 green:0.195 blue:0.195 alpha:1.0];
    NSColor *startColour = [NSColor colorWithCalibratedRed:0.14 green:0.14 blue:0.14 alpha:1.0];
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:startColour, 0.0, endColour, 1.0, nil];
    
    NSRect toolbarRect = frame;
    toolbarRect.size.height = SLF_BOX_TOOLBAR_HEIGHT - 1;
    
    [gradient drawInRect:toolbarRect angle:90.0];
    
    [[NSColor blackColor] setFill];
    NSRectFill(NSMakeRect(0, SLF_BOX_TOOLBAR_HEIGHT, frame.size.width, 1.0));
    
    [[NSColor colorWithCalibratedRed:0.261 green:0.261 blue:0.261 alpha:1.0] setFill];
    NSRectFill(NSMakeRect(0, SLF_BOX_TOOLBAR_HEIGHT - 1, frame.size.width, 1.0));
}
@end
