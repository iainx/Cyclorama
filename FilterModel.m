//
//  FilterModel.m
//  Cyclorama
//
//  Created by iain on 23/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterItem.h"
#import "FilterModel.h"
#import <Quartz/Quartz.h>

@implementation FilterModel

- (id)init
{
    self = [super init];
    
    _categories = [[NSMutableDictionary alloc] init];
    
    [CIPlugIn loadAllPlugIns];
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"example-image"
                                                         ofType:@"png"
                                                    inDirectory:@"Resources/Images"];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
    
    NSArray *filterCategories = @[
        kCICategoryBlur,
        kCICategoryDistortionEffect,
        kCICategoryColorEffect,
        kCICategoryColorAdjustment,
        kCICategoryHalftoneEffect,
        kCICategorySharpen,
        kCICategoryStylize,
        kCICategoryTileEffect
    ];
    
    // This is a list of filters that don't work very well with the filter browser
    NSArray *blackList = @[
        @"CICircularWrap", // Doesn't work
        @"CIShadedMaterial", // Requires other images
        @"CIColorCube", // Requires color
        @"CIStretchCrop", // Doesn't work
        @"CIDroste", // Don't know what it does but it doesn't work
    
        // FIXME: Could we hardcode hacks to make this work in FilterItem and FilterItemView?
        @"CIHoleDistortion" // Default value is 150pixels which is too big for our image.
    ];
    
    for (NSString *filterCategory in filterCategories) {
        NSArray *allFilters = [CIFilter filterNamesInCategory:filterCategory];
        NSMutableArray *filterArray = [[NSMutableArray alloc] init];
        
        for (NSString *filterName in allFilters) {
            if ([blackList containsObject:filterName]) {
                NSLog(@"%@ is blacklisted", filterName);
                continue;
            }
            
            CIFilter *filter = [CIFilter filterWithName:filterName];
            NSArray *inputKeys = [filter inputKeys];
            
            NSUInteger inputImageKey = [inputKeys indexOfObject:kCIInputImageKey];
            if (inputImageKey == NSNotFound) {
                continue;
            }
            
            [filter setDefaults];
            
            FilterItem *item = [[FilterItem alloc] initFromFilter:filter withImage:image];
            
            if ([self findPreviewParameter:inputKeys forFilterItem:item]) {
                [filterArray addObject:item];
            }
        }
        
        // Only add to the category dictionary if we have a filter
        if ([filterArray count] > 0) {
            // Cast to mutable dictionary here because although we know that is what
            // it is, we've only advertised to the outside world that it's a immutable one
            ((NSMutableDictionary *)_categories)[filterCategory] = filterArray;
        }
    }
    
    return self;
}

- (BOOL)findPreviewParameter:(NSArray *)inputKeys
               forFilterItem:(FilterItem *)filterItem
{
    CIFilter *filter = [filterItem filter];
    NSDictionary *attrs = [filter attributes];
    
    for (NSString *key in inputKeys) {
        if ([key isEqualToString:kCIInputImageKey]) {
            continue;
        }
        
        // If our filter has an InputCenter key, then set it to the centre of our image
        if ([key isEqualToString:kCIInputCenterKey]) {
            CIVector *center = [CIVector vectorWithX:34.0 Y:18];
            [filter setValue:center forKey:kCIInputCenterKey];
            continue;
        }
        
        NSDictionary *filterAttrs = [attrs valueForKey:key];
        
        NSString *keyType = [filterAttrs valueForKey:kCIAttributeClass];
        if ([keyType isEqualToString:@"NSNumber"] == NO) {
            continue;
        }
        
        NSNumber *maxPreviewValue = [filterAttrs valueForKey:kCIAttributeSliderMax];
        NSNumber *minPreviewValue = [filterAttrs valueForKey:kCIAttributeSliderMin];
        [filterItem setPreviewKey:key withMinValue:minPreviewValue maxValue:maxPreviewValue];
        return YES;
    }
    
    NSLog(@"No control for %@", [filterItem localizedName]);
    return NO;
}
@end
