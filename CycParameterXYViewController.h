//
//  CycParameterXYViewController.h
//  FilterUIViewTest
//
//  Created by Iain Holmes on 09/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CycParameterViewController.h"

@class CycXYView;

@interface CycParameterXYViewController : CycParameterViewController {
@private
    CycXYView *xyView;
}

@property (readwrite, weak) IBOutlet NSTextField *nameLabel;

@property (readwrite, weak) CIVector *paramValue;
@property (readwrite, assign) double valueX;
@property (readwrite, assign) double valueY;
@property (readwrite, assign) double maxX;
@property (readwrite, assign) double maxY;
@end
