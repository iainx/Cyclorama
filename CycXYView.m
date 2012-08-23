//
//  CycParameterXYView.m
//  FilterUIViewTest
//
//  Created by Iain Holmes on 12/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "CycXYView.h"

@implementation CycXYView

@synthesize minX;
@synthesize maxX;
@synthesize minY;
@synthesize maxY;
@synthesize valueX;
@synthesize valueY;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        minX = 0.0;
        maxX = 100.0;
        minY = 0.0;
        maxY = 100.0;
        valueX = 50.0;
        valueY = 50.0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGRect bounds = NSRectToCGRect([self bounds]);
    CGFloat radius = 10.0;
    
    CGFloat minimumX = CGRectGetMinX(bounds) + 0.5;
    CGFloat middleX = CGRectGetMidX(bounds);
    CGFloat maximumX = CGRectGetMaxX(bounds) - 0.5;
    CGFloat minimumY = CGRectGetMinY(bounds) + 0.5;
    CGFloat middleY = CGRectGetMidY(bounds);
    CGFloat maximumY = CGRectGetMaxY(bounds) - 0.5;
    
    CGContextMoveToPoint(context, minimumX, middleY);
    CGContextAddArcToPoint(context, minimumX, minimumY, middleX, minimumY, radius);
    CGContextAddArcToPoint(context, maximumX, minimumY, maximumX, middleY, radius);
    CGContextAddArcToPoint(context, maximumX, maximumY, middleX, maximumY, radius);
    CGContextAddArcToPoint(context, minimumX, maximumY, minimumX, middleY, radius);
    CGContextClosePath(context);

    CGContextDrawPath(context, kCGPathStroke);

    CGFloat xRatio = valueX / (maxX - minX);
    CGFloat pointX = (bounds.size.width * xRatio);
    CGFloat yRatio = valueY / (maxY - minY);
    CGFloat pointY = (bounds.size.height * yRatio);
    
    CGRect circleRect = CGRectMake(pointX - 5.0, pointY - 5.0, 10.0, 10.0);
    CGContextAddEllipseInRect(context, circleRect);
    
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark - Mouse events

- (void)setValuesFromPoint:(NSPoint)point
{
    NSLog(@"maxX,maxY: %fx%f", maxX, maxY);
    CGFloat xRatio = point.x / [self bounds].size.width;
    [self setValueX:xRatio * (maxX - minX)];
    CGFloat yRatio = point.y / [self bounds].size.height;
    [self setValueY:yRatio * (maxY - minY)];    
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint winPoint = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:winPoint fromView:nil];
    
    [self setValuesFromPoint:point];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint winPoint = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:winPoint fromView:nil];
    
    [self setValuesFromPoint:point];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    
}

- (void)setVector:(CIVector *)vector
{
    valueX = [vector X];
    valueY = [vector Y];
    [self setNeedsDisplay:YES];
}

#pragma mark - Accessors

- (void)setValueX:(double)_valueX
{
    if (_valueX == valueX) {
        return;
    }

    valueX = MAX(minX, MIN(_valueX, maxX));
    [self setNeedsDisplay:YES];
}

- (double)valueX
{
    return valueX;
}

- (void)setValueY:(double)_valueY
{
    if (_valueY == valueY) {
        return;
    }
    
    valueY = MAX(minY, MIN(_valueY, maxY));
    [self setNeedsDisplay:YES];
}

- (double)valueY
{
    return valueY;
}

- (void)setMaxX:(double)_maxX
{
    if (maxX == _maxX) {
        return;
    }
    
    maxX = _maxX;
}

- (double)maxX
{
    return maxX;
}

- (void)setMaxY:(double)_maxY
{
    if (maxY == _maxY) {
        return;
    }
    
    maxY = _maxY;
}

- (double)maxY
{
    return maxY;
}
@end
