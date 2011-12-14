//
//  CycParameterXYView.h
//  FilterUIViewTest
//
//  Created by Iain Holmes on 12/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CycXYView : NSView

@property (readwrite, assign) double minX;
@property (readwrite, assign) double maxX;
@property (readwrite, assign) double minY;
@property (readwrite, assign) double maxY;
@property (readwrite, assign) double valueX;
@property (readwrite, assign) double valueY;

@end
