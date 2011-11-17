//
//  NSString+UUID.m
//  Cyclorama
//
//  Created by Iain Holmes on 07/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)stringWithUUID
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (NSString *)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    
    return [uuidString autorelease];
}

@end
