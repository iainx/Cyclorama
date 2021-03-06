//
//  CycFilterUIView.h
//  FilterUIViewTest
//
//  Created by Iain Holmes on 01/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ActorFilter;
@interface CycFilterUIView : NSView

@property (readwrite, strong) ActorFilter *filter;

- (id)initWithFilter:(ActorFilter *)filter forScreenWidth:(double)_width screenHeight:(double)_height;

@end
