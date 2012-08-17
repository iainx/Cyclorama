//
//  SFArrayController.m
//  Flare
//
//  Created by Iain Holmes on 30/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "CycArrayController.h"

@implementation CycArrayController

- (void)insertObject:(id)object atArrangedObjectIndex:(NSUInteger)index
{
    [super insertObject:object atArrangedObjectIndex:index];
    
    NSDictionary *userInfo = @{@"object": object, @"index": @(index)};
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"ObjectAdded"
                      object:self
                    userInfo:userInfo];
}

- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    id object = [self content][index];
    
    NSDictionary *userInfo = @{@"object":object, @"index": @(index)};
    [nc postNotificationName:@"ObjectRemoved"
                      object:self
                    userInfo:userInfo];
    
    [super removeObjectAtArrangedObjectIndex:index];
}
@end
