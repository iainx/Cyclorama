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

@synthesize filterName;
@synthesize name;
@synthesize parameters;
@synthesize uniqueID;
@synthesize filter = _filter;

- (id)initWithName:(NSString *)_name
    forFilterNamed:(NSString *)_filterName
{
    self = [super init];
    
    if (_name) {
        name = [_name copy];
    } else {
        name = [_filterName copy];
    }
    filterName = [_filterName copy];
    
    uniqueID = [NSString stringWithUUID];
    
    _filter = [CIFilter filterWithName:[self filterName]];
    [_filter setName:uniqueID];
    
    parameters = [[NSMutableDictionary alloc] init];
    
    // Parse the filter details to get the names of the parameters
    [self fillParametersForFilter:_filter];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    parameters = [decoder decodeObjectForKey:@"parameters"];
    filterName = [decoder decodeObjectForKey:@"filterName"];
    name = [decoder decodeObjectForKey:@"name"];
    uniqueID = [decoder decodeObjectForKey:@"uniqueID"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:parameters forKey:@"parameters"];
    [coder encodeObject:filterName forKey:@"filterName"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:uniqueID forKey:@"uniqueID"];
}


- (void)fillParametersForFilter:(CIFilter *)f
{
    NSArray *inputKeys = [_filter inputKeys];
    NSDictionary *attributes = [_filter attributes];
    
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
        parameters[inputName] = param;
        
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

#pragma mark - Accessors
- (CIFilter *)filter
{
    return _filter;
}

@end
