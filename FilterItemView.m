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
#import "CALayer+Images.h"
#import "utils.h"

@implementation FilterItemView {
    CALayer *_imageLayer;
    CATextLayer *_labelLayer;
    CursorLayer *_cursorLayer;
    FilterItem *_filterItem;
    BOOL _isDragging;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    _isDragging = NO;
    
    CALayer *rootLayer = [CALayer layer];
    
    // Debugging
    //[rootLayer setBackgroundColor:[[NSColor redColor] CGColor]];
    
    [self setLayer:rootLayer];
    [self setWantsLayer:YES];
    
    CALayer *bgLayer = [CALayer layer];
    [bgLayer setFrame:CGRectMake(2.0, 12.0, 69.0, 39.0)];
    [bgLayer setCornerRadius:5.0];
    [bgLayer setMasksToBounds:YES];
    
    CGColorRef blackColor = CGColorCreateFromNSColor([NSColor blackColor]);
    [bgLayer setBackgroundColor:blackColor];
    [rootLayer addSublayer:bgLayer];
    CGColorRelease(blackColor);
    
    _imageLayer = [CALayer layer];
    [_imageLayer setFrame:CGRectMake(2.0, 12.0, 69.0, 39.0)];
    [_imageLayer setCornerRadius:5.0];
    [_imageLayer setMasksToBounds:YES];
    [rootLayer addSublayer:_imageLayer];
    
    _labelLayer = [CATextLayer layer];
    [_labelLayer setFrame:CGRectMake(2.0, 2.0, 70.5, 11.0)];
    [_labelLayer setFontSize:9.0];
    [_labelLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
    
    //CGColorRef textColor = CGColorCreateFromNSColor([NSColor blackColor]);
    //[_labelLayer setForegroundColor:textColor];
    //CGColorRelease(textColor);
    
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
    [_imageLayer setValue:@(filterValue) forKeyPath:keyPath];
}

#pragma mark - Mouse methods

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

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"Mouse down on %@", [_filterItem localizedName]);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSLog(@"Mouse up on %@", [_filterItem localizedName]);
    _isDragging = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSLog(@"Mouse dragging on %@", [_filterItem localizedName]);
    if (_isDragging == NO) {
        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        NSArray *pbTypes = @[ CycFilterPasteboardType ];
        [pb declareTypes:pbTypes owner:nil];
        
        // We just put the filter name on the pasteboard
        [pb setData:[[_filterItem filterName] dataUsingEncoding:NSUTF8StringEncoding]
            forType:CycFilterPasteboardType];
        
        // Start the drag
        NSImage *layerImage = [[self layer] createImageForLayer];
        [self dragImage:layerImage
                     at:NSMakePoint(0.0, 0.0)
                 offset:NSZeroSize
                  event:theEvent
             pasteboard:pb
                 source:self
              slideBack:YES];
        
        _isDragging = YES;
    }
}

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

#pragma mark - Tracking area methods

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

#pragma mark - Drag methods

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationNone;
            
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationPrivate;
    }
}

- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session
{
    return YES;
}

@end
