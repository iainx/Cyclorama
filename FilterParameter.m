//
//  FilterParameter.m
//  Cyclorama
//
//  Created by iain on 02/07/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterParameter.h"

@implementation FilterParameter

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
{
    self = [super init];
    
    _name = [name retain];
    _className = [className retain];

    _value = [[NSClassFromString(className) alloc] init];
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_className release];
    [_value release];
    
    [super dealloc];
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
    
    [_defaultValue release];
    
    _defaultValue = [defaultValue retain];
}
@end
