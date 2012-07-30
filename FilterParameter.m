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

@synthesize filter = _filter;
@synthesize name = _name;
@synthesize displayName = _displayName;
@synthesize value = _value;
@synthesize localizedKey = _localizedKey;

@synthesize className = _className;
@synthesize defaultValue = _defaultValue;
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize typeHint = _typeHint;


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
    self =[super init];
    
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
        // defaultValue is a string and we generate it from that
        
    } else if ([_className isEqualToString:@"CIColor"]) {
    } else if ([_className isEqualToString:@"NSAffineTransform"]) {
    } else if ([_className isEqualToString:@"CIImage"]) {
    }
    
    
    _defaultValue = defaultValue;
}
@end
