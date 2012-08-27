//
//  FilterItem.m
//  Cyclorama
//
//  Created by iain on 23/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterItem.h"
#import <Quartz/Quartz.h>

@implementation FilterItem

- (id)initFromFilter:(CIFilter *)filter
           withImage:(CIImage *)image
{
    NSDictionary *attributes;
    
    self = [super init];
    
    attributes = [filter attributes];
 
    _filter = filter;
    [_filter setValue:image
               forKey:kCIInputImageKey];
    _thumbnail = [_filter valueForKey:kCIOutputImageKey];
    
    _filterName = attributes[kCIAttributeFilterName];
    _localizedName = attributes[kCIAttributeFilterDisplayName];
    _localizedDescription = attributes[kCIAttributeDescription];

    return self;
}

@end
