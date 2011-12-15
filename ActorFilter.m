//
//  ActorFilter.m
//  Flare
//
//  Created by iain on 08/07/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "ActorFilter.h"
#import "NSString+UUID.h"

@implementation ActorFilter

@synthesize filterName;
@synthesize name;
@synthesize parameters;
@synthesize uniqueID;
@synthesize filter = _filter;

- (id)initWithName:(NSString *)_name forFilterNamed:(NSString *)_filterName
{
    self = [super init];
    parameters = [[NSMutableDictionary alloc] init];
    
    if (_name) {
        name = [_name copy];
    } else {
        name = [_filterName copy];
    }
    filterName = [_filterName copy];
    
    uniqueID = [[NSString stringWithUUID] retain];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    parameters = [[decoder decodeObjectForKey:@"parameters"] retain];
    filterName = [[decoder decodeObjectForKey:@"filterName"] retain];
    name = [[decoder decodeObjectForKey:@"name"] retain];
    uniqueID = [[decoder decodeObjectForKey:@"uniqueID"] retain];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:parameters forKey:@"parameters"];
    [coder encodeObject:filterName forKey:@"filterName"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:uniqueID forKey:@"uniqueID"];
}

- (void)dealloc
{
    [parameters release];
    [filterName release];
    [name release];
    [uniqueID release];
    
    [super dealloc];
}

#pragma mark - Accessors
- (CIFilter *)filter
{
    if (_filter == nil) {
        _filter = [[CIFilter filterWithName:[self filterName]] retain];
        [_filter setName:uniqueID];
    }
    
    return _filter;
}

- (void)addValue:(id)value forParameter:(NSString *)paramName
{
    [parameters setValue:value
                  forKey:paramName];
}

@end
