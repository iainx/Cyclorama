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

@implementation VideoLayer {
    NSMutableArray *_filterInstances;
    NSMutableArray *_filters;
}

- (id)init
{
    self = [super init];
    
    [self setBackgroundColor:[[NSColor redColor] CGColor]];
    
    // Disable the implicit animations whenever the position changes
    NSDictionary *actions = @{@"position": [NSNull null], @"bounds": [NSNull null], @"hidden": [NSNull null], @"contents": [NSNull null]};
    [self setActions:actions];

    // array to hold the CIFilters to apply to the layer
    _filterInstances = [[NSMutableArray alloc] init];

    _filters = [[NSMutableArray alloc] init];
    _filterController = [[CycArrayController alloc] initWithContent:_filters];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(filterAdded:)
               name:@"ObjectAdded"
             object:_filterController];
    [nc addObserver:self
           selector:@selector(filterRemoved:)
               name:@"ObjectRemoved"
             object:_filterController];

    return self;
}

- (void)filterRemoved:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *index = userInfo[@"index"];
    
    [_filterInstances removeObjectAtIndex:[index unsignedIntegerValue]];
    [self setFilters:_filterInstances];
}

- (void)filterAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *index = userInfo[@"index"];
    ActorFilter *af = userInfo[@"object"];
    
    [_filterInstances insertObject:[af filter]
                           atIndex:[index unsignedIntegerValue]];
    [self setFilters:_filterInstances];
}

- (void)addFilter:(ActorFilter *)filter
          atIndex:(NSUInteger)index
{
    [_filterController insertObject:filter atArrangedObjectIndex:index];
}

- (void)removeFilterAtIndex:(NSUInteger)index
{
    [_filterController removeObjectAtArrangedObjectIndex:index];
}

- (CIFilter *)filterInstanceAtIndex:(NSUInteger)index
{
    return _filterInstances[index];
}

/*- (NSArray *)filters
{
    return [_filterController arrangedObjects];
}*/

@end
