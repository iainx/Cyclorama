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
    NSUInteger itemsPerRow;
    NSUInteger numberOfRows;
    
    NSRange currentRange;
    NSMutableArray *visibleRows; // Contains NSMutableArray of the tiles in the row.
    
    NSUInteger selectedIndex;
}

#define BROWSER_GUTTER_SIZE 10
#define BROWSER_SPACING_SIZE 10

- (void)doVideoBrowserViewInit
{
    [self setWantsLayer:YES];
    
    tileWidth = 152.0;
    itemsPerRow = [self calculateItemsPerRow];
    visibleRows = [[NSMutableArray alloc] init];
    
    selectedIndex = NSUIntegerMax;
    
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

#pragma mark - Calculations

- (NSUInteger)calculateItemsPerRow
{
    CGFloat width = [self frame].size.width;
    NSUInteger ipr = (width - BROWSER_GUTTER_SIZE) / (tileWidth + BROWSER_SPACING_SIZE);
    
    // Minimum items per row has to be 1
    return MAX(ipr, 1);
}

- (NSRect)rectForRow:(NSUInteger)row
{
    CGFloat x = BROWSER_GUTTER_SIZE;
    CGFloat y = BROWSER_GUTTER_SIZE + (row * (134.0 + BROWSER_SPACING_SIZE));
    
    return NSMakeRect(x, y, [self bounds].size.width - (BROWSER_GUTTER_SIZE * 2), 134.0);
}

- (NSUInteger)indexFromRow:(NSUInteger)row column:(NSUInteger)column
{
    return (row * itemsPerRow) + column;
}

#pragma mark - Layout

- (void)layoutTile:(VideoClipLayer *)clipLayer
             atRow:(NSUInteger)row
            column:(NSUInteger)column
{
    CGPoint tilePosition = CGPointMake(BROWSER_GUTTER_SIZE + (column * (152 + BROWSER_SPACING_SIZE)),
                                       BROWSER_GUTTER_SIZE + (row * (134 + BROWSER_SPACING_SIZE)));
    
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
    
    NSMutableArray *rowTiles = [NSMutableArray arrayWithCapacity:itemsPerRow];
    if (visibleRow > [visibleRows count]) {
        [visibleRows addObject:rowTiles];
    } else {
        [visibleRows insertObject:rowTiles atIndex:visibleRow];
    }
    
    for (NSUInteger i = firstTile, column = 0; i < lastTile; i++, column++) {
        VideoClip *clip = [clips objectAtIndex:i];
        
        VideoClipLayer *clipLayer = [[VideoClipLayer alloc] initWithClip:clip];
        
        if (i == selectedIndex) {
            [clipLayer setSelected:YES];
        }
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
    
    // Remove all the tiles in the row
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

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    [super resizeWithOldSuperviewSize:oldSize];
    
    itemsPerRow = [self calculateItemsPerRow];
    NSUInteger newNumberOfRows = [self calculateNumberOfRows];
    
    if (newNumberOfRows != numberOfRows) {
        numberOfRows = newNumberOfRows;
        [self updateHeight];
    }
    
    [visibleRows removeAllObjects];
    [[self layer] setSublayers:[NSArray array]];
    [self addTilesFromVisibleRange];
    
    currentRange = [self visibleRange];
    NSLog(@"Current range: %@", NSStringFromRange(currentRange));
}

- (void)updateTiles
{
    NSRange visibleRange = [self visibleRange];
    NSRange intersectionRange = NSIntersectionRange(visibleRange, currentRange);
    
    // If the stored current range and the visible range are the same
    // we don't need to do anything
    if (visibleRange.location == currentRange.location && NSMaxRange(visibleRange) == NSMaxRange(currentRange)) {
        return;
    }
    
    // If there is no intersection between the stored range and the visible range then we just wipe all
    // the tiles and add the new range
    if (intersectionRange.location == 0 && intersectionRange.length == 0) {
        [visibleRows removeAllObjects];
        [[self layer] setSublayers:[NSArray array]];
        [self addTilesFromVisibleRange];
        
        currentRange = visibleRange;
        return;
    }
    
    if (visibleRange.location < currentRange.location) {
        // Add new rows of tiles along the top
        for (NSInteger i = ((NSInteger)currentRange.location) - 1; i >= (NSInteger)visibleRange.location; i--) {
            [self addTilesInRow:i asVisibleRow:0];
        }
    }
    
    if (visibleRange.location > currentRange.location) {
        // Remove old rows from the top
        for (NSInteger i = currentRange.location; i < visibleRange.location; i++) {
            [self removeTilesInRow:i asVisibleRow:0];
        }
    }
    
    if (NSMaxRange(visibleRange) > NSMaxRange(currentRange)) {
        // Add new rows of tiles along the bottom
        for (NSInteger i = NSMaxRange(currentRange); i < NSMaxRange(visibleRange); i++) {
            [self addTilesInRow:i asVisibleRow:visibleRange.length];
        }
    }
    
    if (NSMaxRange(visibleRange) < NSMaxRange(currentRange)) {
        // Remove the bottom rows
        for (NSInteger i = NSMaxRange(currentRange); i < NSMaxRange(visibleRange); i--) {
            [self removeTilesInRow:i asVisibleRow:visibleRange.length];
        }
    }
    
    currentRange = visibleRange;
}

- (VideoClipLayer *)visibleTileFromIndex:(NSUInteger)index
{
    NSUInteger row, column;
    NSArray *rowTiles;
    
    row = index / itemsPerRow;
    column = index % itemsPerRow;
    
    if (!NSLocationInRange(row, currentRange)) {
        NSLog(@"Row %lu is not in %@", row, NSStringFromRange(currentRange));
        return nil;
    }
    
    rowTiles = visibleRows[row - currentRange.location];
    return rowTiles[column];
}

#pragma mark - Sizing

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
    
    if (firstRow == NSUIntegerMax) {
        return NSMakeRange(0, 0);
    }
    
    if (lastRow == NSUIntegerMax) {
        lastRow = numberOfRows;
    }
    
    return NSMakeRange(firstRow, lastRow - firstRow);
}

- (NSUInteger)calculateNumberOfRows
{
    NSArray *clips = [_videoClipController arrangedObjects];
    NSUInteger clipCount = [clips count];
    NSUInteger rowCount = clipCount / itemsPerRow;
    
    // rowCount is the number of complete rows at this point.
    // If there is a partial row, then we need to count it as well
    if ((clipCount % itemsPerRow) > 0) {
        rowCount++;
    }
    
    return rowCount;
}

- (void)updateHeight
{
    NSRect bounds = [self frame];
    CGFloat newHeight;

    // FIXME: It would be good to be able to not hard code the tile size here
    newHeight = numberOfRows * (134 + BROWSER_SPACING_SIZE) + (2 * BROWSER_GUTTER_SIZE);
    if (newHeight != bounds.size.height) {
        bounds.size.height = newHeight;
        [self setFrame:bounds];
    }
    
    currentRange = [self visibleRange];
}

#pragma mark - Clip handling

- (void)videoClipAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *indexNumber = userInfo[@"index"];
    
    numberOfRows = [self calculateNumberOfRows];
    
    [self updateHeight];
    
    // FIXME: Check if index > the visible range, because then we don't need to update.
    [visibleRows removeAllObjects];
    [[self layer] setSublayers:[NSArray array]];
    [self addTilesFromVisibleRange];
}

- (void)videoClipRemoved:(NSNotification *)note
{
    numberOfRows = [self calculateNumberOfRows];
    [self updateHeight];
    
    // FIXME: Check if index > the visible range, because then we don't need to update
    [visibleRows removeAllObjects];
    [[self layer] setSublayers:[NSArray array]];
    [self addTilesFromVisibleRange];
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
    [self updateHeight];
    
    // FIXME: If there are clips in the model at this point, we should add them
    if ([[_videoClipController arrangedObjects] count] != 0) {
        NSLog(@"There are items in the clip controller");
    }
}

#pragma mark - Scrolling

- (void)clipViewBoundsDidChange:(NSNotification *)note
{
    [self updateTiles];
}

- (void)viewDidMoveToSuperview
{
    NSView *clipView = [self superview];
    
    [clipView setPostsBoundsChangedNotifications:YES];
    NSNotificationCenter *nc;
    
    nc = [NSNotificationCenter defaultCenter];
    // Track scrolling by listening to bounds changes
    [nc addObserver:self
           selector:@selector(clipViewBoundsDidChange:)
               name:NSViewBoundsDidChangeNotification
             object:clipView];
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
    
    NSUInteger index = (maybeRow * itemsPerRow) + maybeCol;
    if (index >= [arrangedObjects count]) {
        // In extra space after the last item
        return nil;
    }
    
    *row = maybeRow;
    *column = maybeCol;
    
    NSRange visibleRange = [self visibleRange];
    NSUInteger visibleRow = maybeRow - visibleRange.location;
    
    return visibleRows[visibleRow][maybeCol];
}

- (CGPoint)point:(CGPoint)p
         inLayer:(CALayer *)layer
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
    NSUInteger newSelectedIndex;
    
    VideoClipLayer *layer = [self findLayerForLocationInView:locationInView
                                                       atRow:&row
                                                    atColumn:&column];
    if (!layer) {
        return;
    }
    
    CGPoint pointInLayer = [self point:locationInView inLayer:layer];
    [layer mouseUp:pointInLayer];
    
    newSelectedIndex = [self indexFromRow:row column:column];
    
    // Deselect the old tile
    if (selectedIndex != NSUIntegerMax) {
        VideoClipLayer *selectedTile = [self visibleTileFromIndex:selectedIndex];
        
        [selectedTile setSelected:NO];
    }
    
    if (newSelectedIndex == selectedIndex) {
        selectedIndex = NSUIntegerMax;
        [_videoClipController setSelectionIndexes:[NSIndexSet indexSet]];
    } else {
        [layer setSelected:YES];
        selectedIndex = newSelectedIndex;
        [_videoClipController setSelectionIndex:newSelectedIndex];
    }
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
    // NSTrackingInVisibleRect will match the tracking area to the bounds of the view when they change
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                                options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

@end
