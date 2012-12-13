//
//  FilterControlBox.h
//  Cyclorama
//
//  Created by iain on 03/11/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFBox.h"

@class FilterControlView;
@interface FilterControlBox : SLFBox

@property (readwrite, strong) FilterControlView *filterControlView;
@end
