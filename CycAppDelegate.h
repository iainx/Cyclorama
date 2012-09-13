//
//  CycAppDelegate.h
//  Cyclorama
//
//  Created by Iain Holmes on 08/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoClipController;
@class FilterModel;

@interface CycAppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) VideoClipController *clipController;
@property (readonly, strong) FilterModel *filterModel;

@end
