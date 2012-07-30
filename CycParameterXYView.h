//
//  CycParameterXYView.h
//  FilterUIViewTest
//
//  Created by Iain Holmes on 13/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CycXYView;
@interface CycParameterXYView : NSView

@property (readwrite, unsafe_unretained) IBOutlet CycXYView *xyView;
@end
