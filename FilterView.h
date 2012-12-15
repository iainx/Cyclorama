//
//  FilterView.h
//  Cyclorama
//
//  Created by iain on 14/12/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ActorFilter;
@interface FilterView : NSView

- (id)initWithFilter:(ActorFilter *)filter;

@end
