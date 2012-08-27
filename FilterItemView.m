//
//  FilterItemView.m
//  Cyclorama
//
//  Created by iain on 25/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "FilterItemView.h"
#import "FilterItem.h"

@implementation FilterItemView {
    FilterItem *_filterItem;
    BOOL _showCursor;
    float _cursorX;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    _showCursor = NO;
    _cursorX = 0.0;
    return self;
}

- (id)initWithFilterItem:(FilterItem *)filterItem
{
    self = [super initWithFrame:NSMakeRect(0.0, 0.0, 74.0, 53.0)];
    
    _filterItem = filterItem;
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_filterItem == nil) {
        return;
    }
    
    CGFloat imageX = 2.0;
    CGFloat imageY = 12.0;
    CGFloat imageW = 69.0;
    CGFloat imageH = 39.0;
    
    NSRect imageRect = NSMakeRect(imageX, imageY, imageW, imageH);
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CIContext *ciContext = [context CIContext];
    CGContextRef cgContext = [context graphicsPort];
    
    CGContextSetRGBFillColor (cgContext, 0, 0, 0, 1);
    
    CGContextSaveGState(cgContext);
    
    // Set up a clippath
    CGMutablePathRef clipPath = CGPathCreateMutable();
    CGFloat radius = 7.5;
    
    CGPathMoveToPoint(clipPath, NULL, imageX, imageY + radius);
    CGPathAddLineToPoint(clipPath, NULL, imageX, imageY + imageH - radius);
    CGPathAddArc(clipPath, NULL, imageX + radius, imageY + imageH - radius, radius, M_PI, M_PI / 2, true);
    CGPathAddLineToPoint(clipPath, NULL, imageX + imageW - radius, imageY + imageH);
    CGPathAddArc(clipPath, NULL, imageX + imageW - radius, imageY + imageH - radius, radius, M_PI / 2, 0.0, true);
    CGPathAddLineToPoint(clipPath, NULL, imageX + imageW, imageY + radius);
    CGPathAddArc(clipPath, NULL, imageX + imageW - radius, imageY + radius, radius, 0.0, - M_PI / 2, true);
    CGPathAddLineToPoint(clipPath, NULL, imageX + radius, imageY);
    CGPathAddArc(clipPath, NULL, imageX + radius, imageY + radius, radius, - M_PI / 2, M_PI, true);
    
    CGContextAddPath(cgContext, clipPath);
    CGContextClip(cgContext);
    
    [ciContext drawImage:[_filterItem thumbnail]
             inRect:imageRect
           fromRect:NSMakeRect(0.0, 0.0, 70.0, 50.0)];
    
    if (_showCursor) {
        CGContextStrokeRect(cgContext, NSMakeRect(_cursorX - 0.5, imageY, 0.5, imageH));
    }
    CGContextRestoreGState(cgContext);
    
    // Draw the title
    CGContextSelectFont (cgContext,
                         "Helvetica",
                         0.9,
                         kCGEncodingMacRoman);
    
    CGContextSetTextDrawingMode(cgContext, kCGTextInvisible);
    const char *name = [[_filterItem localizedName] cStringUsingEncoding:NSUTF8StringEncoding];
    CGContextShowTextAtPoint (cgContext, 0.0, 0.0, name, strlen(name));
    CGPoint textEnd = CGContextGetTextPosition(cgContext);
    
    CGFloat textWidth = textEnd.x;
    CGFloat textOffset = (74 - textWidth) / 2;
    
    CGContextSetTextDrawingMode (cgContext, kCGTextFill);
    CGContextShowTextAtPoint (cgContext, textOffset, 2.0, name, strlen(name));
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    _showCursor = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    _showCursor = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    _cursorX = locationInView.x;
    [self setNeedsDisplay:YES];
}

- (void)viewDidMoveToWindow
{
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:NSMakeRect(2.0, 12.0, 70.0, 39.0)
                                                        options:NSTrackingActiveInActiveApp | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited
                                                          owner:self
                                                       userInfo:nil];
    [self addTrackingArea:area];
}

@end
