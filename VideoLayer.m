//
//  VideoLayer.m
//  Cyclorama
//
//  Created by Iain Holmes on 29/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "VideoLayer.h"
#import "CycArrayController.h"

@implementation VideoLayer

@synthesize filters, videoController;

- (id)init
{
    self = [super init];
    filters = [[NSMutableArray alloc] init];
    filterController = [[CycArrayController alloc] initWithContent:filters];
    
    return self;
}

- (void)dealloc
{
    [filterController release];
    [filters release];
    
    [super dealloc];
}

@end
