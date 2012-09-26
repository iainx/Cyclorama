//
//  VideoBrowserView.m
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoBrowserView.h"
#import "VideoClipLayer.h"
#import "VideoClipController.h"
#import "VideoClip.h"

@implementation VideoBrowserView {
    NSTrackingArea *trackingArea;
    VideoClipLayer *currentLayer;
    CGFloat tileWidth;
    int itemsPerRow;
    NSUInteger numberOfRows;
    
    NSRange currentRange;
    NSMutableArray *visibleRows;
}

#define BROWSER_GUTTER_SIZE 10
#define BROWSER_SPACING_SIZE 10

- (void)doVideoBrowserViewInit
{
    [self setWantsLayer:YES];
    
    CGFloat width = [self frame].size.width;
    
    tileWidth = 152.0;
    itemsPerRow = (width - BROWSER_GUTTER_SIZE) / (tileWidth + BROWSER_SPACING_SIZE);
    
    //[self calculateBestFitForWidth:width];
    visibleRows = [[NSMutableArray alloc] init];
    
    [self createTrackingArea];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self doVideoBrowserViewInit];
    
    return self;
}

- (id)initWithVideoClipController:(VideoClipController *)controller
                            width:(CGFloat)width
{
    NSRect frame = NSZeroRect;
    frame.size.width = width;
    
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self doVideoBrowserViewInit];
    [self setVideoClipController:controller];
    
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

#pragma mark - Layout

- (NSRect)rectForRow:(NSUInteger)row
{
    CGFloat x = BROWSER_GUTTER_SIZE;
    CGFloat y = BROWSER_GUTTER_SIZE + (row * 134.0 + BROWSER_SPACING_SIZE);
    
    return NSMakeRect(x, y, [self bounds].size.width - (BROWSER_GUTTER_SIZE * 2), 134.0);
}

- (NSRange)visibleRange
{
    NSRect visibleRect = [(NSClipView *)[self superview] documentVisibleRect];
    NSUInteger firstRow = NSUIntegerMax;
    NSUInteger lastRow = NSUIntegerMax;
    
    BOOL inRange = NO;
    for (NSUInteger i = 0; i < numberOfRows; i++) {
        NSRect rowRect = [self rectForRow:i];
        
        if (NSIntersectsRect(rowRect, visibleRect)) {
            if (firstRow == NSUIntegerMax) {
                firstRow = i;
                inRange = YES;
            }
        } else {
            if (inRange) {
                lastRow = i;
                break;
            }
        }
    }
    
    if (lastRow == NSUIntegerMax) {
        lastRow = numberOfRows;
    }
    
    return NSMakeRange(firstRow, lastRow - firstRow);
}

- (void)layoutTile:(VideoClipLayer *)clipLayer
             atRow:(NSUInteger)row
            column:(NSUInteger)column
{
    CGPoint tilePosition = CGPointMake(BROWSER_GUTTER_SIZE + (column * (152 + BROWSER_SPACING_SIZE)),
                                       BROWSER_GUTTER_SIZE + (row * (134 + BROWSER_SPACING_SIZE)));
    
//    NSLog(@"Laying out %lu,%lu -> %@", row, column, NSStringFromPoint(tilePosition));
    [clipLayer setPosition:tilePosition];
}

- (void)layoutTiles
{
    [self addTilesFromVisibleRange];
}

- (void)addTilesInRow:(NSUInteger)row
         asVisibleRow:(NSUInteger)visibleRow
{
    NSArray *clips = [_videoClipController arrangedObjects];
    NSUInteger firstTile = row * itemsPerRow;
    NSUInteger lastTile = MIN (firstTile + itemsPerRow, [clips count]);
    
//    NSLog(@"Adding tiles from %lu as row %lu (tile %lu -> %lu)", row, visibleRow, firstTile, lastTile);
    
    NSMutableArray *rowTiles = [NSMutableArray arrayWithCapacity:itemsPerRow];
    if (visibleRow > [visibleRows count]) {
        [visibleRows addObject:rowTiles];
    } else {
        [visibleRows insertObject:rowTiles atIndex:visibleRow];
    }
    
    for (NSUInteger i = firstTile, column = 0; i < lastTile; i++, column++) {
        VideoClip *clip = [clips objectAtIndex:i];
        
        VideoClipLayer *clipLayer = [[VideoClipLayer alloc] initWithClip:clip];
//        NSLog(@"Created clipLayer: %@ for clip: %@", [clipLayer description], [clip description]);
        
        [rowTiles addObject:clipLayer];
        
        [[self layer] addSublayer:clipLayer];
        [self layoutTile:clipLayer atRow:row column:column];
    }
}

- (void)removeTilesInRow:(NSUInteger)row
            asVisibleRow:(NSUInteger)visibleRow
{
    NSMutableArray *rowTiles = [visibleRows objectAtIndex:visibleRow];
    
    [visibleRows removeObjectAtIndex:visibleRow];
    for (NSInteger i = [rowTiles count] - 1; i >= 0; i--) {
        VideoClipLayer *tile = [rowTiles objectAtIndex:i];
        
        [tile removeFromSuperlayer];
        [rowTiles removeObjectAtIndex:i];
    }
}

- (void)addTilesFromVisibleRange
{
    NSRange visibleRange = [self visibleRange];

    for (NSUInteger i = visibleRange.location, vi = 0; i < NSMaxRange(visibleRange); i++, vi++) {
        [self addTilesInRow:i asVisibleRow:vi];
    }
}

- (void)updateTiles
{
    NSRange visibleRange = [self visibleRange];
    NSRange intersectionRange = NSIntersectionRange(visibleRange, currentRange);
    
    if (visibleRange.location == currentRange.location && NSMaxRange(visibleRange) == NSMaxRange(currentRange)) {
        return;
    }
    
    if (intersectionRange.location == 0 && intersectionRange.length == 0) {
        [visibleRows removeAllObjects];
        [[self layer] setSublayers:[NSArray array]];
        [self addTilesFromVisibleRange];
        
        currentRange = visibleRange;
        return;
    }
    
    if (visibleRange.location < currentRange.location) { // Add top
        for (NSInteger i = ((NSInteger)currentRange.location) - 1; i >= (NSInteger)visibleRange.location; i--) {
            [self addTilesInRow:i asVisibleRow:0];
        }
    }
    
    if (visibleRange.location > currentRange.location) { // Remove top
        for (NSInteger i = currentRange.location; i < visibleRange.location; i++) {
            [self removeTilesInRow:i asVisibleRow:0];
        }
    }
    
    if (NSMaxRange(visibleRange) > NSMaxRange(currentRange)) { // Add bottom
        for (NSInteger i = NSMaxRange(currentRange); i < NSMaxRange(visibleRange); i++) {
            [self addTilesInRow:i asVisibleRow:visibleRange.length];
        }
    }
    
    if (NSMaxRange(visibleRange) < NSMaxRange(currentRange)) { // Remove bottom
        for (NSInteger i = NSMaxRange(currentRange); i < NSMaxRange(visibleRange); i--) {
            [self removeTilesInRow:i asVisibleRow:visibleRange.length];
        }
    }
    
    currentRange = visibleRange;
}

- (NSUInteger)calculateNumberOfRows
{
    NSArray *clips = [_videoClipController arrangedObjects];
    NSUInteger clipCount = [clips count];
    NSUInteger rowCount = clipCount / itemsPerRow;
    
    if ((clipCount % itemsPerRow) > 0) {
        rowCount++;
    }
    
    return rowCount;
}

- (void)updateHeight
{
    NSRect bounds = [self frame];

    bounds.size.height = numberOfRows * (134 + BROWSER_SPACING_SIZE) + (2 * BROWSER_GUTTER_SIZE);
    
    [self setFrame:bounds];
}

- (void)videoClipAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *indexNumber = userInfo[@"index"];
    
    numberOfRows = [self calculateNumberOfRows];
    
    //NSLog(@"Added index %@ - %lu %@", [indexNumber description], numberOfRows, NSStringFromRect([self bounds]));
    [self updateHeight];
}

- (void)videoClipRemoved:(NSNotification *)note
{
    numberOfRows = [self calculateNumberOfRows];
}

- (void)setVideoClipController:(VideoClipController *)videoClipController
{
    if (_videoClipController == videoClipController) {
        return;
    }

    _videoClipController = videoClipController;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(videoClipAdded:)
               name:@"ObjectAdded"
             object:videoClipController];
    [nc addObserver:self
           selector:@selector(videoClipRemoved:)
               name:@"ObjectRemoved"
             object:self];
    
    numberOfRows = [self calculateNumberOfRows];
    
    /*
    NSArray *clips = [videoClipController arrangedObjects];
    
    for (VideoClip *clip in clips) {
        VideoClipLayer *clipLayer = [[VideoClipLayer alloc] initWithClip:clip];
        
        [[self layer] addSublayer:clipLayer];
    }
    [self layoutFromIndex:0 forWidth:[self bounds].size.width forTileWidth:tileWidth];
     */
}

// Attempt to work out the best tile width to fit a good number of tiles per row
// FIXME Not really working.
/*
- (CGFloat)calculateBestTileWidthForViewWidth:(CGFloat)width
{
    CGFloat bestWidth;
    CGFloat availableWidth = (width - BROWSER_GUTTER_SIZE);
    int oldItemsPerRow = availableWidth / (tileWidth + BROWSER_SPACING_SIZE);
    CGFloat extraSpace = availableWidth - (oldItemsPerRow * tileWidth);
    int newItemsPerRow = oldItemsPerRow;
    
    if (extraSpace < 0) {
        newItemsPerRow = oldItemsPerRow - 1;
    } else if (extraSpace > 0) {
        newItemsPerRow = oldItemsPerRow + 1;
    }
    
    bestWidth = (availableWidth / newItemsPerRow) - BROWSER_SPACING_SIZE;
    
    return bestWidth;
}
*/

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    [super resizeWithOldSuperviewSize:oldSize];
    
    itemsPerRow = ([self bounds].size.width - BROWSER_GUTTER_SIZE) / (tileWidth + BROWSER_SPACING_SIZE);
    numberOfRows = [self calculateNumberOfRows];
    
    [visibleRows removeAllObjects];
    [[self layer] setSublayers:[NSArray array]];
    [self addTilesFromVisibleRange];

    currentRange = [self visibleRange];
}

#pragma mark - Scrolling

- (void)clipViewBoundsDidChange:(NSNotification *)note
{
    NSClipView *clipView = [note object];
    
    NSRect documentVisibleRect = [clipView documentVisibleRect];
    //NSLog(@"Visible rows %@", NSStringFromRange(currentRange));
    
    [self updateTiles];
}

- (void)viewDidMoveToSuperview
{
    NSView *clipView = [self superview];
    
    [clipView setPostsBoundsChangedNotifications:YES];
    NSNotificationCenter *nc;
    
    nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(clipViewBoundsDidChange:)
               name:NSViewBoundsDidChangeNotification
             object:clipView];
    
    NSRect documentVisibleRect = [(NSClipView *) clipView documentVisibleRect];
    
    /*
    firstVisibleRow = (documentVisibleRect.origin.y - BROWSER_GUTTER_SIZE) / (134.0 + BROWSER_SPACING_SIZE);
    lastVisibleRow = ((documentVisibleRect.origin.y + documentVisibleRect.size.height) - BROWSER_GUTTER_SIZE) / (134.0 + BROWSER_SPACING_SIZE);
    */
    // Now we can do the initial layout correctly
}

#pragma mark - Mouse tracking

- (VideoClipLayer *)findLayerForLocationInView:(NSPoint)locationInView
                                         atRow:(NSInteger *)row
                                      atColumn:(NSInteger *)column
{
    // Remove the gutter size so that all our calculations treat the top right corner of the 1st item as 0,0
    CGFloat viewX = locationInView.x - BROWSER_GUTTER_SIZE;
    CGFloat viewY = locationInView.y - BROWSER_GUTTER_SIZE;
    
    CGFloat widthOfItems = (152.0 + BROWSER_SPACING_SIZE) * itemsPerRow;
    if (viewX > widthOfItems) {
        // In the extra width at the right hand side
        return nil;
    }
    
    int maybeCol = (viewX / (152.0 + BROWSER_SPACING_SIZE));
    if ((maybeCol * (152.0 + BROWSER_SPACING_SIZE)) + 152.0 < viewX) {
        // In the spacing between columns
        return nil;
    }
    
    int maybeRow = (viewY / (134.0 + BROWSER_SPACING_SIZE));
    if ((maybeRow * (134.0 * BROWSER_SPACING_SIZE)) + 134.0 < viewY) {
        // In the spacing between rows
        return nil;
    }
    
    NSArray *arrangedObjects = [_videoClipController arrangedObjects];
    
    int index = (maybeRow * itemsPerRow) + maybeCol;
    if (index >= [arrangedObjects count]) {
        // In extra space after the last item
        return nil;
    }
    
    *row = maybeRow;
    *column = maybeCol;
    
    //return [[self layer] sublayers][index];
    return nil;
}

- (CGPoint)point:(CGPoint)p inLayer:(CALayer *)layer
{
    CGPoint locationInLayer;
    CGPoint layerPosition = [layer position];
    
    locationInLayer.x = p.x - layerPosition.x;
    locationInLayer.y = p.y - layerPosition.y;

    return locationInLayer;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row, column;
    
    VideoClipLayer *layer = [self findLayerForLocationInView:locationInView
                                                       atRow:&row
                                                    atColumn:&column];
    if (!layer) {
        return;
    }

    CGPoint pointInLayer = [self point:locationInView inLayer:layer];
    [layer mouseDown:pointInLayer];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row, column;
    
    VideoClipLayer *layer = [self findLayerForLocationInView:locationInView
                                                       atRow:&row
                                                    atColumn:&column];
    if (!layer) {
        return;
    }
    
    CGPoint pointInLayer = [self point:locationInView inLayer:layer];
    [layer mouseUp:pointInLayer];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow]
                                       fromView:nil];
    NSInteger row, column;
    VideoClipLayer *layer = [self findLayerForLocationInView:locationInView
                                                       atRow:&row
                                                    atColumn:&column];
    
    if (layer == nil) {
        return;
    }
    
    // Check in case we've entered a layer
    [layer mouseEntered];
    currentLayer = layer;
    
    CGPoint locationInLayer;
    [layer mouseMoved:locationInLayer];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if (currentLayer) {
        [currentLayer mouseExited];
        currentLayer = nil;
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow]
                                       fromView:nil];
    NSInteger row, column;
    VideoClipLayer *layer = [self findLayerForLocationInView:locationInView
                                                       atRow:&row
                                                    atColumn:&column];
    if (currentLayer != layer) {
        [currentLayer mouseExited];
        [layer mouseEntered];
        currentLayer = layer;
    }
    
    if (layer == nil) {
        return;
    }
    
    CGPoint locationInLayer;
    CGPoint layerPosition = [layer position];
    
    locationInLayer.x = locationInView.x - layerPosition.x;
    locationInLayer.y = locationInView.y - layerPosition.y;
    [layer mouseMoved:locationInLayer];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSLog(@"Mouse dragged");
}

- (void)createTrackingArea
{
    NSLog(@"Create tracking area");
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                                options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

@end
