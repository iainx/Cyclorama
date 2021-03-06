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
    CALayer *_baseLayer;
    CALayer *_imageLayer;
    CATextLayer *_labelLayer;
    
    BOOL _isObserving;
}

@synthesize clip = _clip;

#define DEFAULT_WIDTH 152.0
#define DEFAULT_IMAGE_HEIGHT 114.0 // gives 4:3 format
#define TEXT_BOX_HEIGHT 18.0
#define FONT_SIZE 11.0
#define SPACING 0.0//2.0
#define DEFAULT_HEIGHT (DEFAULT_IMAGE_HEIGHT + SPACING + TEXT_BOX_HEIGHT)

+ (CGColorRef)selectedBackgroundColor
{
    static CGColorRef selectedColor = NULL;
    
    if (selectedColor == NULL) {
        selectedColor = CGColorCreateGenericGray(0.43, 1.0);
    }
    
    return selectedColor;
}

+ (CGColorRef)normalBackgroundColor
{
    static CGColorRef normalBackgroundColor = NULL;
    
    if (normalBackgroundColor == NULL) {
        normalBackgroundColor = CGColorCreateGenericGray(0.26, 1.0);
    }
    
    return normalBackgroundColor;
}

- (id)initWithClip:(VideoClip *)clip
{
    self = [super init];

    if (!self) {
        return nil;
    }
    
    // Disable the implicit animations whenever the position changes
    NSDictionary *actions = @{@"position": [NSNull null], @"bounds": [NSNull null], @"hidden": [NSNull null], @"contents": [NSNull null]};
    [self setActions:actions];
    
    [self setBounds:CGRectMake(0.0, 0.0, DEFAULT_WIDTH, DEFAULT_HEIGHT)];
    [self setAnchorPoint:CGPointMake(0, 0)];
    [self setShadowOpacity:0.34];
    [self setShadowOffset:CGSizeMake(0.0, 3.0)];
    
    _baseLayer = [CALayer layer];
    [_baseLayer setBounds:CGRectMake(0.0, 0.0, DEFAULT_WIDTH, DEFAULT_HEIGHT - 3)];
    [_baseLayer setAnchorPoint:CGPointMake(0, 0)];
    [_baseLayer setCornerRadius:5.0];
    [_baseLayer setMasksToBounds:YES];
    [self addSublayer:_baseLayer];
    
    _imageLayer = [CALayer layer];
    [_imageLayer setBounds:CGRectMake(0.0, 0.0, DEFAULT_WIDTH, DEFAULT_IMAGE_HEIGHT)];
    [_imageLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
    [_baseLayer addSublayer:_imageLayer];
    
    _labelLayer = [CATextLayer layer];
    [_labelLayer setBounds:CGRectMake(0.0, 0.0, DEFAULT_WIDTH, TEXT_BOX_HEIGHT)];
    [_labelLayer setAnchorPoint:CGPointZero];
    [_labelLayer setPosition:CGPointMake(0.0, DEFAULT_IMAGE_HEIGHT + SPACING)];
    [_labelLayer setFontSize:FONT_SIZE];
    [_labelLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
    [_labelLayer setString:[clip title]];
    [_labelLayer setBackgroundColor:[VideoClipLayer normalBackgroundColor]];
    
    [_labelLayer setAlignmentMode:kCAAlignmentCenter];
    [_labelLayer setTruncationMode:kCATruncationEnd];
    [_baseLayer addSublayer:_labelLayer];

    [self setClip:clip];
    
    // For debugging layout turn this on
    // It allows us to see if multiple layers are laid out on top of each other
    //[self setOpacity:0.25];

    return self;
}

- (NSString *)description
{
    if (_clip) {
        return [_clip description];
    }
    
    return [super description];
}

- (void)dealloc
{
    if (_isObserving) {
        [_clip removeObserver:self
                   forKeyPath:@"thumbnail"];
    }
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

static void *thumbnailContextPointer = &thumbnailContextPointer;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != thumbnailContextPointer) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    
    //NSLog(@"Observed %p", self);
    //NSLog(@"   _clip: %p", _clip);
    //NSLog(@"     keyPath: %@", keyPath);
    //NSLog(@"     context: %p", context);
    //NSLog(@"     _isObserving: %@", _isObserving ? @"YES" : @"NO");
    //NSLog(@"     self: %p", self);
    
    NSImage *thumbnail = [_clip thumbnail];
    
    if (thumbnail) {
        // Observation can happen on any thread and the UI needs updated on
        // the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imageLayer setContents:thumbnail];
        });
    }
    
    if (_isObserving) {
        [_clip removeObserver:self
                   forKeyPath:@"thumbnail"];
        _isObserving = NO;
    }
}

- (void)setClip:(VideoClip *)clip
{
    if (_clip == clip) {
        return;
    }
    
    // Remove the old observer because we no longer care about it being updated
    if (_isObserving) {
        //NSLog(@"Removing %p - %p", self, _clip);
        [_clip removeObserver:self
                   forKeyPath:@"thumbnail"];
        _isObserving = NO;
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
        //NSLog(@"Adding observer: %p - %p (_isObserving: %@)", self, _clip, _isObserving ? @"YES" : @"NO");
        [clip addObserver:self
               forKeyPath:@"thumbnail"
                  options:NSKeyValueObservingOptionNew
                  context:&thumbnailContextPointer];
        _isObserving = YES;
    }
}

- (VideoClip *)clip
{
    return _clip;
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [_labelLayer setBackgroundColor:[VideoClipLayer selectedBackgroundColor]];
    } else {
        [_labelLayer setBackgroundColor:[VideoClipLayer normalBackgroundColor]];
    }
}

- (void)setSizeForWidth:(CGFloat)width
{
    CGFloat imageHeight = (width / 4.0) * 3.0;
    [self setBounds:CGRectMake(0.0, 0.0, width, imageHeight + 2 + TEXT_BOX_HEIGHT)];
}

- (void)mouseEntered
{
    //NSLog(@"Entered %@", [_clip description]);
}

- (void)mouseExited
{
    //NSLog(@"Exited %@", [_clip description]);
}

- (void)mouseMoved:(CGPoint)pointInLayer
{
    //NSLog(@"Moved %@", [_clip description]);
}

- (void)mouseDown:(CGPoint)pointInLayer
{
    //NSLog(@"Down %@", [_clip description]);
}

- (void)mouseUp:(CGPoint)pointInLayer
{
    //NSLog(@"Up %@", [_clip description]);
}

@end
