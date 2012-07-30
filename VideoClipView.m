//
//  VideoClipView.m
//  Cyclorama
//
//  Created by Iain Holmes on 30/10/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "VideoClipView.h"
#import "VideoClip.h"
#import <QTKit/QTKit.h>

@implementation VideoClipView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    NSPoint centrePoint = NSMakePoint(NSWidth(frame) / 2,
                                      NSHeight(frame) / 2);
    NSRect indicatorFrame = NSMakeRect(centrePoint.x - 10.0,
                                       centrePoint.y - 10.0,
                                       20.0, 20.0);

    progressIndicator = [[NSProgressIndicator alloc] initWithFrame:indicatorFrame];
    [progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    [progressIndicator startAnimation:nil];
    
    [self addSubview:progressIndicator];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [thumbnail drawInRect:[self bounds]
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1.0];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    VideoClip *_clip = (VideoClip *)object;
    
    //NSLog(@"%@ changed for %@: %@", keyPath, [_clip filePath], [change description]);
    [self setThumbnail:[_clip thumbnail]];
}

#pragma mark - Accessors

- (void)setClip:(VideoClip *)_clip
{
    if (clip == _clip) {
        return;
    }
    
    clip = _clip;

    [clip addObserver:self
            forKeyPath:@"thumbnail"
               options:NSKeyValueObservingOptionNew
               context:NULL];
}

- (VideoClip *)clip
{
    return clip;
}

- (NSImage *)thumbnail
{
    return thumbnail;
}

- (void)setThumbnail:(NSImage *)_thumbnail
{
    if (_thumbnail == nil) {
        //[progressIndicator stopAnimation:nil];
        [progressIndicator removeFromSuperview];
    }
    
    if (thumbnail == _thumbnail) {
        return;
    }
    
    thumbnail  = _thumbnail;
    
    [progressIndicator stopAnimation:nil];
    [progressIndicator removeFromSuperview];
    
    [self setNeedsDisplay:YES];
}
@end
