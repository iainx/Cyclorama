//
//  SLFLayout.h
//  Autolayout-box
//
//  Created by iain on 21/12/2012.
//  Copyright (c) 2012 iain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SLFLayout : NSView

@property (readwrite, getter = isHorizontal) BOOL horizontal;
@property (readwrite) float borderSize;

- (void)dumpConstraints;
@end
