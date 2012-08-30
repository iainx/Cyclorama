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
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"example-image" ofType:@"png" inDirectory:@"Images"];
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
    for (NSString *filterCategory in filterCategories) {
        NSArray *allFilters = [CIFilter filterNamesInCategory:filterCategory];
        NSMutableArray *filterArray = [[NSMutableArray alloc] init];
        
        for (NSString *filterName in allFilters) {
            CIFilter *filter = [CIFilter filterWithName:filterName];
            NSArray *inputKeys = [filter inputKeys];
            
            NSUInteger inputImageKey = [inputKeys indexOfObject:kCIInputImageKey];
            if (inputImageKey == NSNotFound) {
                continue;
            }
            
            [filter setDefaults];
            
            FilterItem *item = [[FilterItem alloc] initFromFilter:filter withImage:image];
            
            [self findPreviewParameter:inputKeys forFilterItem:item];
            NSLog(@"Created %@", filterName);
            [filterArray addObject:item];
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

- (void)findPreviewParameter:(NSArray *)inputKeys
               forFilterItem:(FilterItem *)filterItem
{
    CIFilter *filter = [filterItem filter];
    NSDictionary *attrs = [filter attributes];
    
    for (NSString *key in inputKeys) {
        if ([key isEqualToString:kCIInputImageKey]) {
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
        break;
    }
}
@end
