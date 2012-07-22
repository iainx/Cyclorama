//
//  VideoClipCollectionItemView.m
//  Cyclorama
//
//  Created by Iain Holmes on 02/11/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "VideoClipCollectionItemView.h"
#import "VideoClipView.h"

@implementation VideoClipCollectionItemView

@synthesize clipView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    NSRect frame = NSMakeRect(5, 20, 155, 69);
    clipView = [[[VideoClipView alloc] initWithFrame:frame] autorelease];
    [self addSubview:clipView];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)setClip:(VideoClip *)clip
{
    [clipView setClip:clip];
}

@end
