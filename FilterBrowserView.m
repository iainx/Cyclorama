//
//  FilterBrowserView.m
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "FilterBrowserView.h"
#import "FilterItem.h"
//#import "FilterItemView.h"
#import "FilterItemLayer.h"
#import "FilterModel.h"
#import "utils.h"

@implementation FilterBrowserView {
    NSMutableArray *_filterItemLayers;
    FilterItemLayer *_currentLayer;
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
        
        /*
        NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(BROWSER_GUTTER_SIZE * 2,
                                                                           yOffset + (BROWSER_CATEGORY_GAP - BROWSER_LABEL_HEIGHT),
                                                                           frameWidth - (BROWSER_GUTTER_SIZE * 4),
                                                                           BROWSER_LABEL_HEIGHT)];
        [label setStringValue:[CIFilter localizedNameForCategory:key]];
        [label setBezeled:NO];
        [label setBordered:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setTextColor:[NSColor whiteColor]];
        
        [self addSubview:label];
         */
        CATextLayer *label = [CATextLayer layer];
        [label setFrame:NSMakeRect(BROWSER_GUTTER_SIZE * 2,
                                   yOffset + (BROWSER_CATEGORY_GAP - BROWSER_LABEL_HEIGHT),
                                   frameWidth - (BROWSER_GUTTER_SIZE * 4),
                                   BROWSER_LABEL_HEIGHT)];
        [label setString:[CIFilter localizedNameForCategory:key]];
        [label setForegroundColor:CGColorCreateFromNSColor([NSColor whiteColor])];
        [label setFontSize:12.0];
        [label setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];

        [[self layer] addSublayer:label];
        
        yOffset += BROWSER_CATEGORY_GAP;

        for (FilterItem *item in categoryArray) {
            //FilterItemView *itemView = [[FilterItemView alloc] initWithFilterItem:item];
            FilterItemLayer *itemLayer = [[FilterItemLayer alloc] initWithFilterItem:item];
            int x;
            
            x = BROWSER_GUTTER_SIZE + (column * 74.0) + ((column - 1) * BROWSER_SPACING_SIZE);
            
            //[itemView setFrameOrigin:NSMakePoint(x, yOffset)];
            [itemLayer setPosition:NSMakePoint(x, yOffset)];
            //[self addSubview:itemView];
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
    
    [self setFrameSize:NSMakeSize(frameWidth, frameHeight)];
    
    NSTrackingArea *area;
    area = [[NSTrackingArea alloc] initWithRect:[self frame]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
                                          owner:self
                                       userInfo:nil];
    [self addTrackingArea:area];
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

@end
