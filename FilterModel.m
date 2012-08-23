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
    NSMutableArray *filterModel;
}

- (id)init
{
    self = [super init];
    
    filterModel = [[NSMutableArray alloc] init];
    
    [CIPlugIn loadAllPlugIns];
    
    NSImage *exampleImage = [NSImage imageNamed:@"example-image.png"];
    CGImageRef imageRef = [exampleImage CGImageForProposedRect:NULL
                                                       context:NULL
                                                         hints:NULL];
    CIImage *image = [CIImage imageWithCGImage:imageRef];
    
    NSArray *allFilters = [CIFilter filterNamesInCategories:nil];
    for (NSString *filterName in allFilters) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        NSArray *inputKeys = [filter inputKeys];
        
        NSUInteger inputImageKey = [inputKeys indexOfObject:kCIInputImageKey];
        if (inputImageKey == NSNotFound) {
            continue;
        }
        
        [filter setDefaults];
        
        FilterItem *item = [[FilterItem alloc] initFromFilter:filter withImage:image];
        
        
        [filterModel addObject:item];
    }
    
    return self;
}

@end
