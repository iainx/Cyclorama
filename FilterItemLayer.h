//
//  FilterItemLayer.h
//  Cyclorama
//
//  Created by iain on 17/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class FilterItem;

@interface FilterItemLayer : CALayer

@property (readonly, strong) FilterItem *filterItem;
- (id)initWithFilterItem:(FilterItem *)filterItem;

- (NSImage *)draggingImage;

- (void)mouseEntered:(NSPoint)locationInLayer;
- (void)mouseExited:(NSPoint)locationInLayer;
- (void)mouseMoved:(NSPoint)locationInLayer;

@end
