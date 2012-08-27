//
//  FilterItem.h
//  Cyclorama
//
//  Created by iain on 23/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FilterItem : NSObject

@property (readwrite, strong) CIFilter *filter;
@property (readwrite, strong) NSString *filterName;
@property (readwrite, strong) NSString *localizedName;
@property (readwrite, strong) NSString *categoryName;
@property (readwrite, strong) CIImage *thumbnail;
@property (readwrite, strong) NSString *localizedDescription;

- (id)initFromFilter:(CIFilter *)filter withImage:(CIImage *)image;

@end
