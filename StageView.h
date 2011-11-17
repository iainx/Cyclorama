//
//  StageView.h
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class CycArrayController;

@interface StageView : NSView {
@private
    CALayer *parentLayer;
    QTMovie *video;
    
    CycArrayController *layerController;
    
    CycArrayController *filterController;
    NSMutableArray *filters;
}

@property (readwrite, retain) QTMovie *video;
@property (readwrite, assign) IBOutlet CycArrayController *filterController;
@property (readwrite, assign) IBOutlet CycArrayController *layerController;
@end
