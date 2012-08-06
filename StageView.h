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
}

@property (readwrite, strong, nonatomic) VideoClip *videoClip;
@property (readwrite, weak) IBOutlet CycArrayController *filterController;
@property (readwrite, weak) IBOutlet CycArrayController *layerController;

- (CIFilter *)filterForCurrentLayerAt:(NSUInteger)index;
@end
