//
//  CycParameterViewController.h
//  FilterUIViewTest
//
//  Created by Iain Holmes on 02/12/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CycParameterViewController.h"

@interface CycParameterLinearViewController : CycParameterViewController

@property (readwrite, assign) double paramValue;
@property (readwrite, assign) double minParamValue;
@property (readwrite, assign) double maxParamValue;

@property (assign) IBOutlet NSTextField *nameLabel;
@property (assign) IBOutlet NSSlider *valueSlider;

@end
