//
//  ActorFilter.h
//  Flare
//
//  Created by iain on 08/07/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class FilterItem;

@interface ActorFilter : NSObject <NSCoding>

@property (readwrite, copy) NSString *filterName;
@property (readwrite, copy) NSString *name;
@property (readonly) NSMutableDictionary *parameters;
@property (readonly) NSString *uniqueID;
@property (readonly) CIFilter *filter;

- (id)initWithName:(NSString *)_name forFilterNamed:(NSString *)_filterName;
- (id)initWithFilterItem:(FilterItem *)filterItem;
@end
