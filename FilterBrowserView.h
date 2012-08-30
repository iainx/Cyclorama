//
//  FilterBrowserView.h
//  Cyclorama
//
//  Created by iain on 28/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FilterModel;

@interface FilterBrowserView : NSView

@property (readwrite, strong, nonatomic) FilterModel *model;

- (id)initWithFilterModel:(FilterModel *)model;
@end
