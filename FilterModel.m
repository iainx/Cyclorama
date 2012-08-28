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

@implementation FilterModel {
    NSMutableArray *_filterModel;
}

- (id)init
{
    self = [super init];
    
    _filterModel = [[NSMutableArray alloc] init];
    [self setContent:_filterModel];
    
    [CIPlugIn loadAllPlugIns];
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"example-image" ofType:@"png" inDirectory:@"Images"];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
    
    NSArray *allFilters = [CIFilter filterNamesInCategory:kCICategoryBlur];

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
        [_filterModel addObject:item];
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
