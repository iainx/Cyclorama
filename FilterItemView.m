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
#import "CursorLayer.h"

@implementation FilterItemView {
    CALayer *_imageLayer;
    CATextLayer *_labelLayer;
    CursorLayer *_cursorLayer;
    FilterItem *_filterItem;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    CALayer *rootLayer = [CALayer layer];
    
    // Debugging
    //[rootLayer setBackgroundColor:[[NSColor redColor] CGColor]];
    
    [self setLayer:rootLayer];
    [self setWantsLayer:YES];
    
    _imageLayer = [CALayer layer];
    [_imageLayer setFrame:CGRectMake(2.0, 12.0, 69.0, 39.0)];
    [_imageLayer setCornerRadius:5.0];
    [_imageLayer setMasksToBounds:YES];
    [rootLayer addSublayer:_imageLayer];
    
    _labelLayer = [CATextLayer layer];
    [_labelLayer setFrame:CGRectMake(2.0, 2.0, 70.0, 11.0)];
    [_labelLayer setFontSize:9.0];
    [_labelLayer setAlignmentMode:kCAAlignmentCenter];
    [_labelLayer setTruncationMode:kCATruncationEnd];
    [rootLayer addSublayer:_labelLayer];
    
    return self;
}

- (id)initWithFilterItem:(FilterItem *)filterItem
{
    self = [self initWithFrame:NSMakeRect(0.0, 0.0, 74.0, 53.0)];
    
    _filterItem = filterItem;
    
    [_imageLayer setContents:[_filterItem thumbnail]];
    [_imageLayer setFilters:@[ [_filterItem filter] ]];

    [_labelLayer setString:[_filterItem localizedName]];

    if ([filterItem previewKey]) {
        _cursorLayer = [[CursorLayer alloc] init];
        [_cursorLayer setFrame:CGRectMake(2.0, 12.0, 69.0, 39.0)];
        [[self layer] addSublayer:_cursorLayer];
    }
    
    return self;
}

- (void)setFilterToNormalizedValue:(CGFloat)normalizedValue
{
    CGFloat filterValue;
    
    filterValue = [_filterItem convertNormalizedValueToPreviewValue:normalizedValue];
    
    NSString *keyPath = [NSString stringWithFormat:@"filters.%@.%@",
                         [_filterItem filterName],
                         [_filterItem previewKey]];
    NSLog(@"Setting %@", keyPath);
    [_imageLayer setValue:@(filterValue) forKeyPath:keyPath];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [_cursorLayer setShowCursor:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [_cursorLayer setShowCursor:NO];
    
    [self setFilterToNormalizedValue:0.1];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    CGFloat normalizedValue;
    
    [_cursorLayer setCursorPosition:locationInView.x];
    
    normalizedValue = (locationInView.x - 2.0) / 68.0;
    [self setFilterToNormalizedValue:normalizedValue];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSLog(@"Mouse dragging on %@", [_filterItem localizedName]);
}

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

- (void)viewDidMoveToWindow
{
    if ([_filterItem previewKey]) {
        NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                            options:NSTrackingActiveInActiveApp | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited
                                                              owner:self
                                                           userInfo:nil];
        
        [self addTrackingArea:area];
    }
}

@end
