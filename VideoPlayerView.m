//
//  VideoPlayerView.m
//  Cyclorama
//
//  Created by iain on 22/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoPlayerView.h"
#import "CycArrayController.h"
#import "VideoLayer.h"
#import "VideoClip.h"

@implementation VideoPlayerView {
    CGFloat _scale;
    
    AVPlayer *_currentPlayer;
    AVPlayerItem *_currentPlayerItem;
    CGFloat _videoRate;
}

@synthesize clip = _clip;
@synthesize layerController = _layerController;

static void
initSelf (VideoPlayerView *self)
{
    self->_videoRate = 1.0;
    
    [self setWantsLayer:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    initSelf(self);
    return self;
}

// FIXME: Size is based on 720p screen. Should use actual screen size
- (void)resizeAndPositionVideoLayer:(VideoLayer *)videoLayer
{
    NSRect frameRect;
    NSRect bounds;
    
    // Calculate the frame scale
    CGFloat scale = 1.0;
    
    bounds = [self bounds];
    
    if (!NSEqualRects(bounds, NSZeroRect)) {
        CGRect layerFrame;
        
        frameRect = NSInsetRect(bounds, 10.0, 10.0);
        if (frameRect.size.height < frameRect.size.width) {
            _scale = frameRect.size.height / 720.0;
            
            // Check that the scaled width isn't bigger than then frame width
            if (1280.0 * _scale > frameRect.size.width) {
                _scale = frameRect.size.width / 1280.0;
                layerFrame = CGRectMake(0.0, 0.0, frameRect.size.width, 720.0 * _scale);
            } else {
                layerFrame = CGRectMake(0.0, 0.0, 1280.0 * _scale, frameRect.size.height);
            }
        } else {
            _scale = frameRect.size.width / 1280.0;
            // Check that the scaled width isn't bigger than then frame width
            if (720.0 * _scale > frameRect.size.height) {
                _scale = frameRect.size.height / 720.0;
                layerFrame = CGRectMake(0.0, 0.0, 1280.0 * _scale, frameRect.size.height);
            } else {
                layerFrame = CGRectMake(0.0, 0.0, frameRect.size.width, 720.0 * _scale);
            }
        }
        if (_scale == 0.0) {
            _scale = 1.0;
        }
        
        //NSLog(@"Setting bounds to %@ for %@", NSStringFromRect(layerFrame), NSStringFromRect(frameRect));
        [videoLayer setContentsScale:_scale];
        [videoLayer setBounds:layerFrame];
        [videoLayer setPosition:CGPointMake(NSMidX(frameRect), NSMidY(frameRect))];
    }
    
    [videoLayer setContentsScale:scale];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    NSArray *layers = [_layerController arrangedObjects];
    for (VideoLayer *layer in layers) {
        [self resizeAndPositionVideoLayer:layer];
    }
}

/*
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blueColor] setFill];
    NSRectFill(NSInsetRect([self bounds], 0.0, 10.0));
}
*/
- (VideoLayer *)currentLayer
{
    NSArray *selectedLayers = [_layerController selectedObjects];
    
    return selectedLayers[0];
}

- (void)itemFinished:(NSNotification *)note
{
    AVPlayerItem *item = [note object];
    
    [item seekToTime:kCMTimeZero];
}

- (void)setClip:(VideoClip *)clip
{
    if (clip == _clip) {
        return;
    }
    
    if (_currentPlayer) {
        [_currentPlayer pause];
    }

    NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
    if (_currentPlayerItem) {
        [ns removeObserver:self
                      name:AVPlayerItemDidPlayToEndTimeNotification
                    object:_currentPlayerItem];
    }
    
    AVAsset *asset = [clip asset];
    _currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    _currentPlayer = [AVPlayer playerWithPlayerItem:_currentPlayerItem];
    
    [_currentPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [ns addObserver:self
           selector:@selector(itemFinished:)
               name:AVPlayerItemDidPlayToEndTimeNotification
             object:_currentPlayerItem];
    
    // setMute:NO doesn't appear to do anything
    [_currentPlayer setVolume:0.0];

    VideoLayer *currentLayer = [self currentLayer];
    
    [currentLayer setPlayer:_currentPlayer];
    [_currentPlayer play];
    [_currentPlayer setRate:_videoRate];
}

- (VideoClip *)clip
{
    return _clip;
}

- (void)setRate:(float)rate
{
    VideoLayer *currentLayer = [self currentLayer];
    AVPlayer *player = [currentLayer player];
    
    _videoRate = rate;
    [player setRate:rate];
}

- (void)layerAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    VideoLayer *layer = userInfo[@"object"];
    
    [self resizeAndPositionVideoLayer:layer];
    [[self layer] addSublayer:layer];
}

- (void)setLayerController:(CycArrayController *)layerController
{
    if (_layerController != nil) {
        NSLog(@"Trying to set layerController more than once");
        return;
    }
    
    _layerController = layerController;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(layerAdded:)
               name:@"ObjectAdded"
             object:layerController];
}

- (CycArrayController *)layerController
{
    return _layerController;
}

@end
