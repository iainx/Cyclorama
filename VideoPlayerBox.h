//
//  VideoPlayerBox.h
//  Cyclorama
//
//  Created by iain on 09/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFBox.h"

@class VideoPlayerView;
@interface VideoPlayerBox : SLFBox

@property (readonly, strong) VideoPlayerView *playerView;
@end
