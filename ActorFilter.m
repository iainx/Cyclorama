//
//  ActorFilter.m
//  Flare
//
//  Created by iain on 08/07/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>
#import "ActorFilter.h"
#import "FilterParameter.h"
#import "NSString+UUID.h"

@implementation ActorFilter

- (id)initWithName:(NSString *)name
    forFilterNamed:(NSString *)filterName
{
    self = [super init];
    
    if (_name) {
        _name = [_name copy];
    } else {
        _name = [filterName copy];
    }
    _filterName = [filterName copy];
    
    _uniqueID = [NSString stringWithUUID];
    
    _filter = [CIFilter filterWithName:filterName];
    [_filter setName:_uniqueID];
    
    _parameters = [[NSMutableDictionary alloc] init];
    
    // Parse the filter details to get the names of the parameters
    [self fillParametersForFilter:_filter];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    _parameters = [decoder decodeObjectForKey:@"parameters"];
    _filterName = [decoder decodeObjectForKey:@"filterName"];
    _name = [decoder decodeObjectForKey:@"name"];
    _uniqueID = [decoder decodeObjectForKey:@"uniqueID"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_parameters forKey:@"parameters"];
    [coder encodeObject:_filterName forKey:@"filterName"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_uniqueID forKey:@"uniqueID"];
}


- (void)fillParametersForFilter:(CIFilter *)f
{
    NSArray *inputKeys = [_filter inputKeys];
    NSDictionary *attributes = [_filter attributes];
    
    [self setName:attributes [kCIAttributeFilterDisplayName]];
    
    NSLog(@"HEllo? %@", [inputKeys description]);
    for (NSString *inputName in inputKeys) {
        if ([inputName isEqualToString:@"inputImage"]) {
            continue;
        }
        
        NSDictionary *attrs = [attributes valueForKey:inputName];
        
        NSString *className = attrs[@"CIAttributeClass"];
        FilterParameter *param = [[FilterParameter alloc] initWithName:inputName
                                                             className:className
                                                             forFilter:self];
        
        [param setMinValue:attrs[@"CIAttributeSliderMin"]];
        [param setMaxValue:attrs[@"CIAttributeSliderMax"]];
        [param setDefaultValue:attrs[@"CIAttributeDefault"]];
        [param setDisplayName:attrs[@"CIAttributeDisplayName"]];
        
        NSLog(@"Adding param %@", inputName);
        _parameters[inputName] = param;
        
        /*
         NSString *attrClass = [attrs objectForKey:@"CIAttributeClass"];
         NSLog(@"AttrType: %@", attrClass);
         
         if ([attrClass isEqualToString:@"CIVector"]) {
         } else if ([attrClass isEqualToString:@"NSNumber"]) {
         } else {
         NSLog(@"Unknown class: %@ - %@", attrClass, inputName);
         }
         */
    }
}

@end
