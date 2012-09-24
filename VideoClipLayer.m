//
//  VideoBrowserLayer.m
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoClipLayer.h"
#import "VideoClip.h"

@implementation VideoClipLayer {
    CALayer *_imageLayer;
    CATextLayer *_labelLayer;
    
    BOOL _isObserving;
}

@synthesize clip = _clip;

#define DEFAULT_WIDTH 152.0
#define DEFAULT_IMAGE_HEIGHT 114.0 // gives 4:3 format
#define TEXT_BOX_HEIGHT 18.0
#define FONT_SIZE 11.0
#define SPACING 2.0
#define DEFAULT_HEIGHT (DEFAULT_IMAGE_HEIGHT + SPACING + TEXT_BOX_HEIGHT)

- (id)initWithClip:(VideoClip *)clip
{
    self = [super init];

    if (!self) {
        return nil;
    }
    
    [self setClip:clip];
    
    // Disable the implicit animations whenever the position changes
    NSDictionary *actions = @{@"position": [NSNull null], @"bounds": [NSNull null]};
    [self setActions:actions];
    
    [self setBounds:CGRectMake(0.0, 0.0, DEFAULT_WIDTH, DEFAULT_HEIGHT)];
    [self setAnchorPoint:CGPointMake(0, 0)];
    
    _imageLayer = [CALayer layer];
    [_imageLayer setCornerRadius:5.0];
    [_imageLayer setMasksToBounds:YES];
    [_imageLayer setBounds:CGRectMake(0.0, 0.0, DEFAULT_WIDTH, DEFAULT_IMAGE_HEIGHT)];
    [_imageLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
    [self addSublayer:_imageLayer];
    
    _labelLayer = [CATextLayer layer];
    [_labelLayer setBounds:CGRectMake(0.0, 0.0, DEFAULT_WIDTH, TEXT_BOX_HEIGHT)];
    [_labelLayer setAnchorPoint:CGPointZero];
    [_labelLayer setPosition:CGPointMake(0.0, DEFAULT_IMAGE_HEIGHT + SPACING)];
    [_labelLayer setFontSize:FONT_SIZE];
    [_labelLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
    [_labelLayer setString:[clip title]];
    
    [_labelLayer setAlignmentMode:kCAAlignmentCenter];
    [_labelLayer setTruncationMode:kCATruncationEnd];
    [self addSublayer:_labelLayer];
    
    return self;
}

- (void)layoutSublayers
{
    CGRect bounds = [self bounds];
    CGFloat width = bounds.size.width;
    
    // Calculate the 4:3 height for a given width
    // Resize the image and reposition the label
    CGFloat imageHeight = (width / 4.0) * 3.0;
    
    [_imageLayer setBounds:CGRectMake(0, 0, width, imageHeight)];
    [_labelLayer setBounds:CGRectMake(0, 0, width, TEXT_BOX_HEIGHT)];
    [_labelLayer setPosition:CGPointMake(0.0, imageHeight + SPACING)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != _clip || [keyPath isEqualToString:@"thumbnail"] == NO) {
        return;
    }
    
    NSImage *thumbnail = [_clip thumbnail];
    
    if (thumbnail) {
        // Observation can happen on any thread and the UI needs updated on
        // the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imageLayer setContents:thumbnail];
        });
    }
    
    [_clip removeObserver:self
               forKeyPath:@"thumbnail"];
    _isObserving = NO;
}

- (void)setClip:(VideoClip *)clip
{
    if (_clip == clip) {
        return;
    }
    
    // Remove the old observer because we no longer care about it being updated
    if (_isObserving) {
        [_clip removeObserver:self
                   forKeyPath:@"thumbnail"];
    }
    
    _clip = clip;
    
    [_labelLayer setString:[clip title]];
    //[_details setStringValue:@""];
    
    BOOL haveThumbnail = [clip requestThumbnail];
    if (haveThumbnail) {
        NSImage *thumbnail = [clip thumbnail];
        [_imageLayer setContents:thumbnail];
        _isObserving = NO;
    } else {
        [clip addObserver:self
               forKeyPath:@"thumbnail"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        _isObserving = YES;
    }
}

- (VideoClip *)clip
{
    return _clip;
}

- (void)setSizeForWidth:(CGFloat)width
{
    CGFloat imageHeight = (width / 4.0) * 3.0;
    [self setBounds:CGRectMake(0.0, 0.0, width, imageHeight + 2 + TEXT_BOX_HEIGHT)];
}

- (void)mouseEntered
{
    NSLog(@"Entered");
}

- (void)mouseExited
{
    NSLog(@"Exited");
}

- (void)mouseMoved:(CGPoint)pointInLayer
{
    NSLog(@"Moved");
}

- (void)mouseDown:(CGPoint)pointInLayer
{
    NSLog(@"Down");
}

- (void)mouseUp:(CGPoint)pointInLayer
{
    NSLog(@"Up");
}
@end
