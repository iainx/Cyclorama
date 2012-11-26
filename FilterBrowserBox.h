//
//  FilterBrowserBox.h
//  Cyclorama
//
//  Created by iain on 16/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFBox.h"
#import "FilterBrowserDelegate.h"

@class FilterModel;
@interface FilterBrowserBox : SLFBox

- (void)setFilterModel:(FilterModel *)model;
- (void)setViewDelegate:(id<FilterBrowserDelegate>)viewDelegate;

@end
