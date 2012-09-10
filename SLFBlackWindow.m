//
//  SLFBlackWindow.m
//  test-hud
//
//  Created by iain on 06/09/2012.
//  Copyright (c) 2012 iain. All rights reserved.
//

#import "SLFBlackWindow.h"

@implementation SLFBlackWindow {
    float titleBarHeight;
}

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)styleMask
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag;
{
	NSUInteger newStyle;
	if (styleMask & NSTexturedBackgroundWindowMask) {
		newStyle = styleMask;
	} else {
		newStyle = (NSTexturedBackgroundWindowMask | styleMask);
	}
    
	if (self = [super initWithContentRect:contentRect styleMask:newStyle backing:bufferingType defer:flag]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidResize:)
                                                     name:NSWindowDidResizeNotification
                                                   object:self];
        
        [self setupTitleBar];
        [self setBackgroundColor:[self styledBackground]];
        
        _topBorderHeight = 25.0;
		return self;
	}
    
	return nil;
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	[self setBackgroundColor:[self styledBackground]];
}

- (NSColor *)styledBackground
{
	// delta between frame and content done this way to future proof
	if (!titleBarHeight) {
		titleBarHeight = [self frame].size.height - [[self contentView] frame].size.height;
	}
    
	NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];

    NSColor *borderStartColor = [NSColor colorWithDeviceRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    
    // FIXME: Use whiteColor because I don't know how to change the title text colour to white
    // and it is too dark to use the nice dark colour.
    //NSColor *borderEndColor = [NSColor colorWithDeviceRed:0.26 green:0.26 blue:0.26 alpha:1.0];
    NSColor *borderEndColor = [NSColor whiteColor];
    
    NSGradient *styledGradient = [[NSGradient alloc] initWithColorsAndLocations:borderStartColor, 0.0,
                                  borderEndColor, 1.0, nil];
	// Set min width of temporary pattern image to prevent flickering at small widths
	float minWidth = 300.0;
	float width = MAX (minWidth, [self frame].size.width);
	
	// Begin drawing into our main image
	[bg lockFocus];
	
	// Composite current background color into bg
	[borderStartColor set];
	NSRectFill(NSMakeRect(0, 0, [bg size].width, [bg size].height - 22));
    
    [styledGradient drawInRect:NSMakeRect(0, [bg size].height - titleBarHeight,
                                          width, titleBarHeight)
                         angle:90];
    
	// draw the line between title and content
    [[NSColor blackColor] setFill];
	NSRectFill(NSMakeRect(0, [bg size].height - titleBarHeight, [bg size].width, 1.0));
	
	[bg unlockFocus];
	
	return [NSColor colorWithPatternImage:bg];
}

- (void)setupTitleBar
{
    // FIXME: Ideally we'd set the titlebar text colour here
}
@end
