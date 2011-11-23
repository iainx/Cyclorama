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
@class VideoClip;

@interface StageView : NSView {
@private
    CALayer *parentLayer;
    QTMovieLayer *videoLayer;
    VideoClip *videoClip;
    
    CycArrayController *layerController;
    
    CycArrayController *filterController;
}

@property (readwrite, retain) VideoClip *videoClip;
@property (readwrite, assign) IBOutlet CycArrayController *filterController;
@property (readwrite, assign) IBOutlet CycArrayController *layerController;
@end
