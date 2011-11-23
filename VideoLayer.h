//
//  VideoLayer.h
//  Cyclorama
//
//  Created by Iain Holmes on 29/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <QTKit/QTKit.h>

@class CycArrayController;

@interface VideoLayer : QTMovieLayer { 
@private
    CycArrayController *filterController;
    NSMutableArray *filters;
    
    NSArrayController *videoController;
}

@property (readwrite, retain) NSArrayController *videoController;

- (void)addFilter:(CIFilter *)filter atIndex:(NSUInteger)index;
- (void)removeFilterAtIndex:(NSUInteger)index;

@end
