//
//  SLFBoxDelegate.h
//  Cyclorama
//
//  Created by iain on 22/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLFBoxDelegate <NSObject>

@optional
- (BOOL)boxWillClose;
- (void)boxDidClose;

- (BOOL)boxWillOpen;
- (BOOL)boxDidOpen;

@end
