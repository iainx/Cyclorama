//
//  FilterParameter.m
//  Cyclorama
//
//  Created by iain on 02/07/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterParameter.h"
#import "ActorFilter.h"

@implementation FilterParameter

- (id)initWithName:(NSString *)name
         className:(NSString *)className
         forFilter:(ActorFilter *)filter
{
    self = [super init];
    
    _filter = filter; // Weak reference;
    
    _name = name;
    _className = className;

    _value = [[NSClassFromString(className) alloc] init];
    
    return self;
}

- (id)init
{
    self = [super init];
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone
{
    FilterParameter *copy = [[[self class] allocWithZone:zone] init];

    copy->_filter = nil;
    copy->_name = nil;
    copy->_className = nil;
    copy->_displayName = nil;
    copy->_defaultValue = nil;
    copy->_localizedKey = nil;
    copy->_maxValue = nil;
    copy->_minValue = nil;
    copy->_typeHint = nil;
    copy->_value = nil;
    
    [copy setFilter:[self filter]];
    [copy setName:[self name]];
    [copy setClassName:[self className]];
    [copy setDisplayName:[self displayName]];
    [copy setDefaultValue:[self defaultValue]];
    [copy setLocalizedKey:[self localizedKey]];
    [copy setMaxValue:[self maxValue]];
    [copy setMinValue:[self minValue]];
    [copy setTypeHint:[self typeHint]];
    [copy setValue:[self value]];
    
    return copy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ [%@ - %@]: %@", _name, _className, _typeHint, [_value description]];
}

- (void)setDefaultValue:(id)defaultValue
{
    if (defaultValue == _defaultValue) {
        return;
    }

    if ([_className isEqualToString:@"CIVector"]) {
        NSLog(@"CIVector %@", [defaultValue description]);
    } else if ([_className isEqualToString:@"CIColor"]) {
        NSLog(@"CIColor default value: %@ %@", [defaultValue description], [self description]);
    } else if ([_className isEqualToString:@"NSAffineTransform"]) {
        NSLog(@"NSAffineTransform default value: %@", [defaultValue description]);
    } else if ([_className isEqualToString:@"CIImage"]) {
        NSLog(@"CIImage default value: %@", [defaultValue description]);
    }
    
    _defaultValue = defaultValue;
    
    // Set up the value from the default
    [self setValue:defaultValue];
}
@end
