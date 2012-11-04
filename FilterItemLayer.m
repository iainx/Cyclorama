//
//  FilterItemLayer.m
//  Cyclorama
//
//  Created by iain on 17/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterItemLayer.h"
#import "CALayer+Images.h"
#import "FilterItem.h"
#import "CursorLayer.h"
#import "utils.h"

@implementation FilterItemLayer {
    CALayer *_imageLayer;
    CATextLayer *_labelLayer;
    CursorLayer *_cursorLayer;
}

- (id)initWithFilterItem:(FilterItem *)filterItem
{
    self = [super init];
    
    [self setBounds:NSMakeRect(0.0, 0.0, 74.0, 53.0)];
    [self setAnchorPoint:CGPointMake(0, 0)];
    
    _filterItem = filterItem;

    CALayer *bgLayer = [CALayer layer];
    [bgLayer setFrame:CGRectMake(2.0, 2.0, 69.0, 39.0)];
    [bgLayer setCornerRadius:5.0];
    [bgLayer setMasksToBounds:YES];
    
    CGColorRef blackColor = CGColorCreateFromNSColor([NSColor blackColor]);
    [bgLayer setBackgroundColor:blackColor];
    [self addSublayer:bgLayer];
    
    _imageLayer = [CALayer layer];
    [_imageLayer setFrame:CGRectMake(0.0, 0.0, 69.0, 39.0)];
    [_imageLayer setCornerRadius:5.0];
    [_imageLayer setMasksToBounds:YES];
    [_imageLayer setContents:[_filterItem thumbnail]];
    [_imageLayer setFilters:@[ [_filterItem filter] ]];

    [bgLayer addSublayer:_imageLayer];
    
    _labelLayer = [CATextLayer layer];
    [_labelLayer setFrame:CGRectMake(2.0, 42.0, 70.5, 11.0)];
    [_labelLayer setFontSize:9.0];
    [_labelLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
    
    //CGColorRef textColor = CGColorCreateFromNSColor([NSColor blackColor]);
    //[_labelLayer setForegroundColor:textColor];
    //CGColorRelease(textColor);
    
    [_labelLayer setAlignmentMode:kCAAlignmentCenter];
    [_labelLayer setTruncationMode:kCATruncationEnd];
    [self addSublayer:_labelLayer];
    
    [_labelLayer setString:[_filterItem localizedName]];
    
    if ([filterItem previewKey]) {
        _cursorLayer = [[CursorLayer alloc] init];
        [_cursorLayer setFrame:CGRectMake(0.0, 0.0, 69.0, 39.0)];
        [bgLayer addSublayer:_cursorLayer];
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
    [_imageLayer setValue:@(filterValue) forKeyPath:keyPath];
}

#pragma mark - Dragging

- (NSImage *)draggingImage
{
    return [_imageLayer createImageForLayer];
}

#pragma mark - Tracking Area methods

- (void)mouseEntered:(NSPoint)locationInLayer
{
    if ([_filterItem previewKey] == nil) {
        return;
    }
    
    [_cursorLayer setShowCursor:YES];
}

- (void)mouseExited:(NSPoint)locationInLayer
{
    if ([_filterItem previewKey] == nil) {
        return;
    }
    
    [_cursorLayer setShowCursor:NO];
    
    [self setFilterToNormalizedValue:0.1];
}

- (void)mouseDown:(NSPoint)locationInLayer
{
    NSLog(@"Mouse down");
}

- (void)mouseUp:(NSPoint)locationInLayer
{
    NSLog(@"Mouse up");
}

- (void)mouseMoved:(NSPoint)locationInLayer
{
    CGFloat normalizedValue;
 
    if ([_filterItem previewKey] == nil) {
        return;
    }
    
    [_cursorLayer setCursorPosition:locationInLayer.x];
    
    normalizedValue = (locationInLayer.x - 2.0) / 68.0;
    [self setFilterToNormalizedValue:normalizedValue];
}

@end
