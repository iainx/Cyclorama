//
//  FilterBrowserView.m
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "CALayer+Images.h"
#import "FilterBrowserView.h"
#import "FilterItem.h"
#import "FilterItemLayer.h"
#import "FilterModel.h"
#import "utils.h"

@implementation FilterBrowserView {
    NSMutableArray *_filterItemLayers;
    FilterItemLayer *_currentLayer;
    BOOL _isDragging;
    NSSize _intrinsicSize;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithFilterModel:(FilterModel *)model
{
    self = [super initWithFrame:NSZeroRect];
    
    _filterItemLayers = [[NSMutableArray alloc] init];
    [self setWantsLayer:YES];
    [self setModel:model];
    _isDragging = NO;
    _intrinsicSize = NSZeroSize;
    
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

#define BROWSER_GUTTER_SIZE 5
#define BROWSER_SPACING_SIZE 2
#define BROWSER_ITEMS_PER_ROW 3
#define BROWSER_CATEGORY_GAP 25
#define BROWSER_LABEL_HEIGHT 20

- (void)setModel:(FilterModel *)model
{
    if (model == _model) {
        return;
    }
    
    _model = model;
    
    if (_model == nil) {
        return;
    }
    
    NSDictionary *categories = [model categories];
    float frameHeight;
    float frameWidth;
    __block NSInteger rowCount = 0;
    __block int yOffset = BROWSER_GUTTER_SIZE;

    frameWidth = (BROWSER_GUTTER_SIZE * 2) + (74.0 * BROWSER_ITEMS_PER_ROW) + (2 * BROWSER_SPACING_SIZE);

    // Layout the subviews and calculate the size of the view
    [categories enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *categoryArray = (NSArray *) obj;
        NSUInteger c = [categoryArray count];
        int column = 0, i = 0;
        
        rowCount += (c / BROWSER_ITEMS_PER_ROW);
        if (c % BROWSER_ITEMS_PER_ROW > 0) {
            rowCount++;
        }
        
        CATextLayer *label = [CATextLayer layer];
        [label setFrame:NSMakeRect(BROWSER_GUTTER_SIZE * 2,
                                   yOffset + (BROWSER_CATEGORY_GAP - BROWSER_LABEL_HEIGHT),
                                   frameWidth - (BROWSER_GUTTER_SIZE * 4),
                                   BROWSER_LABEL_HEIGHT)];
        [label setString:[CIFilter localizedNameForCategory:key]];
        CGColorRef white = CGColorCreateFromNSColor([NSColor whiteColor]);
        [label setForegroundColor:white];
        CGColorRelease(white);
        
        [label setFontSize:12.0];
        [label setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];

        [[self layer] addSublayer:label];
        
        yOffset += BROWSER_CATEGORY_GAP;

        for (FilterItem *item in categoryArray) {
            FilterItemLayer *itemLayer = [[FilterItemLayer alloc] initWithFilterItem:item];
            int x;
            
            x = BROWSER_GUTTER_SIZE + (column * 74.0) + ((column - 1) * BROWSER_SPACING_SIZE);
            
            [itemLayer setPosition:NSMakePoint(x, yOffset)];
            [[self layer] addSublayer:itemLayer];
            
            i++;
            column++;
            
            [_filterItemLayers addObject:itemLayer];
            
            if (column >= BROWSER_ITEMS_PER_ROW && i < [categoryArray count]) {
                column = 0;
                yOffset += 53.0 + BROWSER_SPACING_SIZE;
            }
        }

        yOffset += 53.0;
    }];
    
    // yOffset still needs the bottom gutter added to it
    frameHeight = yOffset + BROWSER_GUTTER_SIZE;
    
    _intrinsicSize = NSMakeSize(frameWidth, frameHeight);
    NSLog(@"Setting intrinsic size: %@", NSStringFromSize(_intrinsicSize));
    [self invalidateIntrinsicContentSize];
    
    NSTrackingArea *area;
    area = [[NSTrackingArea alloc] initWithRect:[self frame]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
                                          owner:self
                                       userInfo:nil];
    [self addTrackingArea:area];
}

- (NSSize)intrinsicContentSize
{
    NSLog(@"intrinsic content is %@", NSStringFromSize(_intrinsicSize));
    return _intrinsicSize;
}

#pragma mark - Tracking Area methods
- (FilterItemLayer *)findLayerForPoint:(NSPoint)locationInView
{
    for (FilterItemLayer *layer in _filterItemLayers) {
        if ([layer hitTest:locationInView] != nil) {
            return layer;
        }
    }
    
    return nil;
}

- (NSPoint)locationInLayer:(FilterItemLayer *)layer fromLocationInView:(NSPoint)pointInView
{
    NSPoint layerOrigin = [layer position];
    
    NSPoint locationInLayer;
    locationInLayer.x = pointInView.x - layerOrigin.x;
    locationInLayer.y = pointInView.y - layerOrigin.y;
    
    return locationInLayer;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    FilterItemLayer *layer = [self findLayerForPoint:pointInView];
    
    if (layer == nil) {
        return;
    }
    
    _currentLayer = layer;
    NSPoint locationInLayer = [self locationInLayer:layer fromLocationInView:pointInView];
    [layer mouseEntered:locationInLayer];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if (_currentLayer == nil) {
        return;
    }
    
    // We don't need a point for mouseExited really as it's outside the layer
    [_currentLayer mouseExited:NSZeroPoint];
    _currentLayer = nil;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    FilterItemLayer *layer = [self findLayerForPoint:pointInView];
    NSPoint locationInLayer;
    
    if (layer == nil || layer != _currentLayer) {
        // We've left the _currentLayer so tell it about exit
        if (_currentLayer) {
            [_currentLayer mouseExited:NSZeroPoint];
            _currentLayer = nil;
        }
        
        // We've entered this new layer
        if (layer) {
            locationInLayer = [self locationInLayer:layer fromLocationInView:pointInView];
            [layer mouseEntered:locationInLayer];
            _currentLayer = layer;
        }
        
        return;
    }
    
    locationInLayer = [self locationInLayer:layer fromLocationInView:pointInView];
    [layer mouseMoved:locationInLayer];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    FilterItemLayer *layer = [self findLayerForPoint:pointInView];
    
    if (layer == nil) {
        return;
    }
    
    FilterItem *filterItem = [layer filterItem];
    
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    NSArray *pbTypes = @[ CycFilterPasteboardType ];
    [pb declareTypes:pbTypes owner:nil];
    
    NSLog(@"Dragging %@", [filterItem filterName]);
    // We just put the filter name on the pasteboard
    [pb setData:[[filterItem filterName] dataUsingEncoding:NSUTF8StringEncoding]
        forType:CycFilterPasteboardType];
    
    // Start the drag
    NSPoint location = NSMakePoint([layer position].x, [layer position].y + [layer bounds].size.height);
    NSImage *layerImage = [layer draggingImage];
    [self dragImage:layerImage
                 at:location
             offset:NSZeroSize
              event:theEvent
         pasteboard:pb
             source:self
          slideBack:YES];

}

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([theEvent clickCount] != 2) {
        return;
    }
    
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    FilterItemLayer *layer = [self findLayerForPoint:pointInView];
    
    if (layer == nil) {
        return;
    }
    
    FilterItem *filterItem = [layer filterItem];
    
    if ([self delegate]) {
        [[self delegate] addFilter:filterItem];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
}
@end
