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

@property (readwrite, assign) IBOutlet NSTextField *nameLabel;

@property (readwrite, assign) CIVector *paramValue;
@property (readwrite, assign) double valueX;
@property (readwrite, assign) double valueY;
@end
