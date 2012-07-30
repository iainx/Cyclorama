//
//  FilterParameter.h
//  Cyclorama
//
//  Created by iain on 02/07/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActorFilter;
@interface FilterParameter : NSObject <NSCopying>

@property (readwrite, nonatomic, weak) ActorFilter *filter;
@property (readwrite, nonatomic, strong) id value;
@property (readwrite, nonatomic, strong) NSString *className;

@property (readwrite, nonatomic, strong) NSString *name;
@property (readwrite, nonatomic, strong) NSString *localizedKey;
@property (readwrite, nonatomic, strong) NSString *displayName;

@property (readwrite, nonatomic, strong) id defaultValue;
@property (readwrite, nonatomic, strong) NSNumber *maxValue;
@property (readwrite, nonatomic, strong) NSNumber *minValue;
@property (readwrite, nonatomic, strong) NSString *typeHint;

- (id)initWithName:(NSString *)name
         className:(NSString *)className
         forFilter:(ActorFilter *)filter;
@end
