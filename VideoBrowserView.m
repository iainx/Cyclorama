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
    CGFloat tileWidth;
    int itemsPerRow;
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

- (void)layoutFromIndex:(NSUInteger)index
               forWidth:(CGFloat)width
           forTileWidth:(CGFloat)newTileWidth
{
    NSArray *sublayers = [[self layer] sublayers];
    NSUInteger i;
    NSUInteger row, col;

    row = index / itemsPerRow;
    col = index % itemsPerRow;
    
    float x = BROWSER_GUTTER_SIZE + (col * (152.0 + BROWSER_SPACING_SIZE));
    float y = BROWSER_GUTTER_SIZE + (row * (134.0 + BROWSER_SPACING_SIZE));

    for (i = index; i  < [sublayers count]; i++) {
        VideoClipLayer *clipLayer = sublayers[i];
        /*
        if (tileWidth != newTileWidth) {
            [clipLayer setSizeForWidth:newTileWidth];
        }
        */
        if (x + [clipLayer bounds].size.width >= width - BROWSER_GUTTER_SIZE) {
            x = BROWSER_GUTTER_SIZE;
            y += (BROWSER_SPACING_SIZE + [clipLayer bounds].size.height);
        }
        [clipLayer setPosition:CGPointMake(x, y)];
        x += [clipLayer bounds].size.width + BROWSER_SPACING_SIZE;
    }
    
    [self setFrameSize:NSMakeSize([self frame].size.width, y + 134.0 + BROWSER_GUTTER_SIZE)];
    //tileWidth = newTileWidth;
}

- (void)videoClipAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    VideoClip *clip = userInfo[@"object"];
    NSNumber *indexNumber = userInfo[@"index"];
    
    VideoClipLayer *clipLayer = [[VideoClipLayer alloc] initWithClip:clip];
    
    [[self layer] addSublayer:clipLayer];
    [self layoutFromIndex:[indexNumber unsignedIntegerValue]
                 forWidth:[self bounds].size.width
             forTileWidth:tileWidth];
}

- (void)videoClipRemoved:(NSNotification *)note
{
    
}

- (void)setVideoClipController:(VideoClipController *)videoClipController
{
    if (_videoClipController == videoClipController) {
        return;
    }

    NSLog(@"set video clip controller");

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
    
    NSArray *clips = [videoClipController arrangedObjects];
    
    for (VideoClip *clip in clips) {
        VideoClipLayer *clipLayer = [[VideoClipLayer alloc] initWithClip:clip];
        
        [[self layer] addSublayer:clipLayer];
    }
    [self layoutFromIndex:0 forWidth:[self bounds].size.width forTileWidth:tileWidth];
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
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    // Relayout
    //CGFloat bestTileWidth = [self calculateBestTileWidthForViewWidth:frameRect.size.width];
    itemsPerRow = (frameRect.size.width - BROWSER_GUTTER_SIZE) / (tileWidth + BROWSER_SPACING_SIZE);
    [self layoutFromIndex:0 forWidth:frameRect.size.width forTileWidth:tileWidth];
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
    
    return [_videoClipController arrangedObjects][index];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint locationInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row, column;
    
    VideoClipLayer *layer = [self findLayerForLocationInView:locationInView
                                                       atRow:&row
                                                    atColumn:&column];
    
    if (layer) {
        NSLog(@"Mouse down in %p (%ld,%ld)", layer, row, column);
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSLog(@"Mouse up");
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSLog(@"Mouse entered");
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSLog(@"Mouse exited");
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSLog(@"Mouse moved");
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
