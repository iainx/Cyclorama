//
//  CursorLayer.m
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "CursorLayer.h"

@implementation CursorLayer

- (id)init
{
    self = [super init];
    
    [self setCornerRadius:5.0];
    [self setMasksToBounds:YES];

    _cursorPosition = 0.0;
    _showCursor = NO;
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (_showCursor == NO) {
        return;
    }
    
    CGContextMoveToPoint(ctx, _cursorPosition, 0);
    CGContextAddLineToPoint(ctx, _cursorPosition, [self bounds].size.height);
    CGContextStrokePath(ctx);
}

- (void)setCursorPosition:(CGFloat)cursorPosition
{
    if (_cursorPosition == cursorPosition) {
        return;
    }
    
    _cursorPosition = cursorPosition;
    
    if (_showCursor == NO) {
        return;
    }
    [self setNeedsDisplay];
}

- (void)setShowCursor:(BOOL)showCursor
{
    if (_showCursor == showCursor) {
        return;
    }
    
    _showCursor = showCursor;
    [self setNeedsDisplay];
}
@end
