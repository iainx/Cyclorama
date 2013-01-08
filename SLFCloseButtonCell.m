//
//  SLFCloseButtonCell.m
//  Cyclorama
//
//  Created by iain on 08/01/2013.
//  Copyright (c) 2013 Sleep(5). All rights reserved.
//

#import "SLFCloseButtonCell.h"
#import "NSBezierPath+MCAdditions.h"

@implementation SLFCloseButtonCell

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

- (void)drawIconInBox:(NSRect)boxRect
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    switch (_type) {
        case SLFButtonCellTypeClose: {
            NSPoint bottomLeft = NSMakePoint(boxRect.origin.x, NSMaxY(boxRect));
            NSPoint topRight = NSMakePoint(NSMaxX(boxRect), boxRect.origin.y);
            NSPoint bottomRight = NSMakePoint(topRight.x, bottomLeft.y);
            NSPoint topLeft = NSMakePoint(bottomLeft.x, topRight.y);
         
            [path moveToPoint:bottomLeft];
            [path lineToPoint:topRight];
            [path moveToPoint:bottomRight];
            [path lineToPoint:topLeft];

            break;
        }
            
        case SLFButtonCellTypeOpen: {
            NSPoint topRight = NSMakePoint(NSMaxX(boxRect), boxRect.origin.y);
            NSPoint bottomRight = NSMakePoint(topRight.x, NSMaxY(boxRect));
            NSPoint midLeft = NSMakePoint(boxRect.origin.x, NSMidY(boxRect));
            
            [path moveToPoint:bottomRight];
            [path lineToPoint:midLeft];
            [path lineToPoint:topRight];
            break;
        }

        case SLFButtonCellTypeMaximise: {
            NSPoint topLeft = NSMakePoint(NSMinX(boxRect), boxRect.origin.y);
            NSPoint bottomLeft = NSMakePoint(topLeft.x, NSMaxY(boxRect));
            NSPoint midRight = NSMakePoint(NSMaxX(boxRect), NSMidY(boxRect));
            
            [path moveToPoint:bottomLeft];
            [path lineToPoint:midRight];
            [path lineToPoint:topLeft];
            break;
        }
            
        case SLFButtonCellTypeMinimise: {
            NSPoint midLeft = NSMakePoint(NSMinX(boxRect), NSMidY(boxRect));
            NSPoint midRight = NSMakePoint(NSMaxX(boxRect), NSMidY(boxRect));
            NSPoint midBottom = NSMakePoint(NSMidX(boxRect), NSMaxY(boxRect));
            
            [path moveToPoint:midLeft];
            [path moveToPoint:midBottom];
            [path moveToPoint:midRight];
            break;
        }
            
        default: {
            break;
        }
    }
    
    [SNRWindowButtonCrossColor set];
    [path setLineWidth:2.f];
    [path stroke];
}

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
    
    // Draw the icon
    CGFloat boxDimension = floor(drawingRect.size.width * cos(45.f)) - SNRWindowButtonCrossInset;
    CGFloat origin = round((drawingRect.size.width - boxDimension) / 2.f);
    
    NSRect boxRect = NSMakeRect(1.f + origin, origin, boxDimension, boxDimension);
    
    [self drawIconInBox:boxRect];
    
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
