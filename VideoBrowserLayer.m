//
//  VideoBrowserLayer.m
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoBrowserLayer.h"
#import "VideoClip.h"

@implementation VideoBrowserLayer {
    CALayer *_imageLayer;
    CATextLayer *_labelLayer;
    
    BOOL _isObserving;
}

@synthesize clip = _clip;

- (id)initWithClip:(VideoClip *)clip
{
    self = [super init];

    if (!self) {
        return nil;
    }
    
    _clip = clip;
    [clip addObserver:self
           forKeyPath:@"thumbnail"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    _isObserving = YES;
    
    [self setBounds:CGRectMake(0.0, 0.0, 150.0, 150.0)];
    [self setAnchorPoint:CGPointMake(0, 0)];
    
    _imageLayer = [CALayer layer];
    [_imageLayer setCornerRadius:5.0];
    [_imageLayer setMasksToBounds:YES];
    [_imageLayer setBounds:CGRectMake(0.0, 0.0, 150.0, 130.0)];
    [_imageLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
    [self addSublayer:_imageLayer];
    
    _labelLayer = [CATextLayer layer];
    [_labelLayer setBounds:CGRectMake(0.0, 0.0, 150.0, 18.0)];
    [_labelLayer setAnchorPoint:CGPointZero];
    [_labelLayer setPosition:CGPointMake(0.0, 132.0)];
    [_labelLayer setFontSize:11.0];
    [_labelLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
    //[_labelLayer setBackgroundColor:CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0)];
    //[_labelLayer setForegroundColor:CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0)];
    [_labelLayer setString:[clip title]];
    
    [_labelLayer setAlignmentMode:kCAAlignmentCenter];
    [_labelLayer setTruncationMode:kCATruncationEnd];
    [self addSublayer:_labelLayer];
    
    return self;
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
    
    NSImage *thumbnail = [clip thumbnail];
    if (thumbnail) {
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

@end