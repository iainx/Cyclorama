//
//  CycFilterColourViewController.h
//  Cyclorama
//
//  Created by iain on 14/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CycParameterViewController.h"

@interface CycParameterColourViewController : CycParameterViewController

@property (strong) NSColor *paramValue;

@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSColorWell *colourPicker;

@end
