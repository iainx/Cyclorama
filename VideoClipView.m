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

    progressIndicator = [[[NSProgressIndicator alloc] initWithFrame:indicatorFrame] autorelease];
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

- (void)setClip:(VideoClip *)_clip
{
    if (clip == _clip) {
        return;
    }
    
    [clip release];
    clip = [_clip retain];
    
    NSLog(@"VideoClipView clip set starting thumbnail for: %@", [clip filePath]);
    
    if (thumbnail_queue == NULL) {
        thumbnail_queue = dispatch_queue_create("com.sleepfive.thumbnail", NULL);
        dispatch_queue_t high = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
        dispatch_set_target_queue(thumbnail_queue, high);
    }
    
    if (main_queue == NULL) {
        main_queue = dispatch_get_main_queue();
    }
    /*
    dispatch_async(thumbnail_queue, ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        QTMovie *movie = [clip movie];
        
        [QTMovie enterQTKitOnThread];
        [movie attachToCurrentThread];
        
        NSImage *t = [[clip thumbnail] retain];
        NSLog(@"Got thumbnail for %@", [clip filePath]);
        
        [movie detachFromCurrentThread];
        [QTMovie exitQTKitOnThread];
        
        [pool release];
        
        dispatch_async(main_queue, ^{
            [self setThumbnail:t];
            [t release];
        });
    });
    */
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
    
    [thumbnail release];
    thumbnail  = [_thumbnail retain];
    
    [progressIndicator stopAnimation:nil];
    [progressIndicator removeFromSuperview];
    
    [self setNeedsDisplay:YES];
}
@end
