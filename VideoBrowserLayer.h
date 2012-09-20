//
//  VideoBrowserLayer.h
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class VideoClip;

@interface VideoBrowserLayer : CALayer

@property (readwrite, strong) VideoClip *clip;

- (id)initWithClip:(VideoClip *)clip;

@end