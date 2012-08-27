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
    CIImage *image = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
    
    NSArray *allFilters = [CIFilter filterNamesInCategory:kCICategoryBlur];
    NSLog(@"Ohooooo");
    for (NSString *filterName in allFilters) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        NSArray *inputKeys = [filter inputKeys];
        
        NSUInteger inputImageKey = [inputKeys indexOfObject:kCIInputImageKey];
        if (inputImageKey == NSNotFound) {
            continue;
        }
        
        [filter setDefaults];
        
        FilterItem *item = [[FilterItem alloc] initFromFilter:filter withImage:image];
        
        NSLog(@"Created %@", filterName);
        [_filterModel addObject:item];
    }
    
    return self;
}

@end
