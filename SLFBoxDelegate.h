//
//  SLFBoxDelegate.h
//  Cyclorama
//
//  Created by iain on 22/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLFBox;
@protocol SLFBoxDelegate <NSObject>

@optional
- (BOOL)box:(SLFBox *)box willCloseToRect:(NSRect)newRect;
- (void)boxDidClose:(SLFBox *)box;

- (BOOL)box:(SLFBox *)box willOpenToRect:(NSRect)newRect;
- (BOOL)boxDidOpen:(SLFBox *)box;

@end
