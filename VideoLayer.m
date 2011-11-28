//
//  VideoLayer.m
//  Cyclorama
//
//  Created by Iain Holmes on 29/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "ActorFilter.h"
#import "VideoLayer.h"
#import "CycArrayController.h"

@implementation VideoLayer

@synthesize videoController;

- (id)init
{
    self = [super init];
    
    // array to hold the CIFilters to apply to the layer
    filters = [[NSMutableArray alloc] init];
//    filterController = [[CycArrayController alloc] initWithContent:filters];
    
    return self;
}

- (void)dealloc
{
//    [filterController release];
    [filters release];
    
    [super dealloc];
}

- (void)addFilter:(CIFilter *)filter
          atIndex:(NSUInteger)index
{
    [filters insertObject:filter atIndex:index];
    [self setFilters:filters];
}

- (void)removeFilterAtIndex:(NSUInteger)index
{
    [filters removeObjectAtIndex:index];
    [self setFilters:filters];
}

- (CIFilter *)filterAtIndex:(NSUInteger)index
{
    return [filters objectAtIndex:index];
}
@end
