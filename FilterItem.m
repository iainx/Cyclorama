//
//  FilterItem.m
//  Cyclorama
//
//  Created by iain on 23/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterItem.h"
#import <Quartz/Quartz.h>

@implementation FilterItem {
    CGFloat _minValue;
    CGFloat _maxValue;
}

- (id)initFromFilter:(CIFilter *)filter
           withImage:(NSImage *)image
{
    NSDictionary *attributes;
    
    self = [super init];
     
    _filter = filter;
    _thumbnail = image;
    
    attributes = [filter attributes];
    _filterName = attributes[kCIAttributeFilterName];
    
    [_filter setName:_filterName];
    _localizedName = attributes[kCIAttributeFilterDisplayName];
    _localizedDescription = attributes[kCIAttributeDescription];

    return self;
}

- (CGFloat)convertNormalizedValueToPreviewValue:(CGFloat)value
{
    CGFloat actualVal;
    
    actualVal = _minValue + ((_maxValue - _minValue) * value);
    return actualVal;
}

- (void)setPreviewKey:(NSString *)key
         withMinValue:(NSNumber *)minPreviewValue
             maxValue:(NSNumber *)maxPreviewValue
{
    CGFloat initialValue;
    
    _previewKey = [key copy];
    _minValue = [minPreviewValue floatValue];
    _maxValue = [maxPreviewValue floatValue];
    
    initialValue = _minValue + ((_maxValue - _minValue) * 0.1);
    [_filter setValue:@(initialValue) forKey:_previewKey];
}
@end
