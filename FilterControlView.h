//
//  FilterControlView.h
//  Cyclorama
//
//  Created by iain on 12/12/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CycArrayController;
@interface FilterControlView : NSView

@property (readwrite, strong) CycArrayController *layerController;
@end
