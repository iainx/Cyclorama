//
//  VideoBrowswerCell.m
//  Cyclorama
//
//  Created by iain on 10/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoClip.h"
#import "VideoBrowserCell.h"

@implementation VideoBrowserCell {
    BOOL _isObserving;
}

@synthesize clip = _clip;

- (id)initWithReusableIdentifier:(NSString *)identifier
{
    self = [super initWithReusableIdentifier:identifier];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

- (void)prepareForReuse
{
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
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
        [_imageView setImage:thumbnail];
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
    
    [_title setStringValue:[clip title]];
    [_details setStringValue:@""];
    
    NSImage *thumbnail = [clip thumbnail];
    if (thumbnail) {
        [_imageView setImage:thumbnail];
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
