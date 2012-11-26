//
//  FilterBrowserDelegate.h
//  Cyclorama
//
//  Created by iain on 06/11/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterItem;
@protocol FilterBrowserDelegate <NSObject>

- (void)addFilter:(FilterItem *)filter;

@end
