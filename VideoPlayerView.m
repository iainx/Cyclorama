//
//  VideoPlayerView.m
//  Cyclorama
//
//  Created by iain on 22/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoPlayerView.h"
#import "VideoLayer.h"
#import "VideoClip.h"

@implementation VideoPlayerView {
    VideoLayer *_childLayer;
    CGFloat _scale;
    
    AVPlayer *_currentPlayer;
    AVPlayerItem *_currentPlayerItem;
}

@synthesize clip = _clip;

static void
initSelf (VideoPlayerView *self)
{
    self->_childLayer = [[VideoLayer alloc] init];
    [self->_childLayer setBackgroundColor:[[NSColor redColor] CGColor]];
    // Disable the implicit animations whenever the position changes
    NSDictionary *actions = @{@"position": [NSNull null], @"bounds": [NSNull null], @"hidden": [NSNull null], @"contents": [NSNull null]};
    [self->_childLayer setActions:actions];

    [self resizeAndPositionVideoLayer];
    
    [self setWantsLayer:YES];
    [[self layer] addSublayer:self->_childLayer];
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
- (void)resizeAndPositionVideoLayer
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
        [_childLayer setContentsScale:_scale];
        [_childLayer setBounds:layerFrame];
        [_childLayer setPosition:CGPointMake(NSMidX(frameRect), NSMidY(frameRect))];
    }
    
    [_childLayer setContentsScale:scale];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self resizeAndPositionVideoLayer];
}

/*
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blueColor] setFill];
    NSRectFill(NSInsetRect([self bounds], 0.0, 10.0));
}
 */

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
    
    [_childLayer setPlayer:_currentPlayer];
    [_currentPlayer play];
}

- (VideoClip *)clip
{
    return _clip;
}

- (void)setRate:(float)rate
{
    AVPlayer *player = [_childLayer player];
    
    [player setRate:rate];
}
@end
