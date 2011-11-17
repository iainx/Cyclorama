//
//  ActorFilter.h
//  Flare
//
//  Created by iain on 08/07/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActorFilter : NSObject <NSCoding> {
@private
    NSMutableDictionary *parameters;
    NSString *filterName; // Name of the filter plugin
    NSString *name; // Name of this filter.
    NSString *uniqueID; // Unique ID to use when identifying this filter
}

@property (readwrite, copy) NSString *filterName;
@property (readwrite, copy) NSString *name;
@property (readonly) NSMutableDictionary *parameters;
@property (readonly) NSString *uniqueID;

- (id)initWithName:(NSString *)_name forFilterNamed:(NSString *)_filterName;
- (void)addValue:(id)value forParameter:(NSString *)paramName;

@end
