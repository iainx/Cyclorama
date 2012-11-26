//
//  FilterBrowserView.h
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilterBrowserDelegate.h"

@class FilterModel;

@interface FilterBrowserView : NSView

@property (readwrite, strong, nonatomic) FilterModel *model;
@property (readwrite, weak) id<FilterBrowserDelegate> delegate;

- (id)initWithFilterModel:(FilterModel *)model;
@end
