//
//  VideoBrowserLayer.h
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class VideoClip;

@interface VideoClipLayer : CALayer

@property (readwrite, strong) VideoClip *clip;
@property (readwrite, getter = isSelected) BOOL selected;

- (id)initWithClip:(VideoClip *)clip;
- (void)setSizeForWidth:(CGFloat)width;

- (void)mouseEntered;
- (void)mouseExited;
- (void)mouseMoved:(CGPoint)pointInLayer;
- (void)mouseDown:(CGPoint)pointInLayer;
- (void)mouseUp:(CGPoint)pointInLayer;

@end
