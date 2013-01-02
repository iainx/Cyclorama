//
//  FilterControlView.m
//  Cyclorama
//
//  Created by iain on 12/12/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "CycArrayController.h"
#import "FilterControlView.h"
#import "VideoLayer.h"
#import "ActorFilter.h"
#import "FilterView.h"
#import "SharedTypes.h"

@implementation FilterControlView {
    NSMutableArray *_filterViews;
    CycArrayController *_currentLayerFilterController;
}

@synthesize layerController = _layerController;

- (id)init
{
    self = [super initWithFrame:NSZeroRect];
    if (!self) {
        return nil;
    }
    
    [self setHorizontal:NO];
    
    _filterViews = [NSMutableArray array];
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}
/*
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blueColor] set];
    NSRectFill([self bounds]);
}
*/

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &selectionIndexContext) {
        VideoLayer *selectedLayer = [_layerController selectedObjects][0];
        
        [self setupFilterController:[selectedLayer filterController]];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Filter controls

static void *selectionIndexContext = &selectionIndexContext;

- (void)filterAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    ActorFilter *af = userInfo[@"object"];
    NSNumber *index = userInfo[@"index"];

    FilterView *newView = [[FilterView alloc] initWithFilter:af];

    [_filterViews insertObject:newView atIndex:[index unsignedIntegerValue]];
    
    [self addSubview:newView];
}

- (void)filterRemoved:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *index = userInfo[@"index"];
    
    [_filterViews removeObjectAtIndex:[index unsignedIntegerValue]];
}

- (void)setUIForFilters:(NSArray *)filters
{
    // Remove all the old filters
    for (FilterView *view in _filterViews) {
        [view removeFromSuperviewWithoutNeedingDisplay];
    }
    
    for (ActorFilter *af in filters) {
        FilterView *view = [[FilterView alloc] initWithFilter:af];
        
        [self addSubview:view];
        [_filterViews addObject:view];
    }
}

- (void)setupFilterController:(CycArrayController *)filterController
{
    if (filterController == _currentLayerFilterController) {
        return;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (_currentLayerFilterController) {
        [nc removeObserver:self
                      name:CycArrayControllerObjectAdded
                    object:_currentLayerFilterController];
        [nc removeObserver:self
                      name:CycArrayControllerObjectRemoved
                    object:_currentLayerFilterController];
    }

    _currentLayerFilterController = filterController;
    [nc addObserver:self
           selector:@selector(filterAdded:)
               name:CycArrayControllerObjectAdded
             object:_currentLayerFilterController];
    [nc addObserver:self
           selector:@selector(filterRemoved:)
               name:CycArrayControllerObjectRemoved
             object:_currentLayerFilterController];
    
    NSArray *filters = [_currentLayerFilterController arrangedObjects];
    
    [self setUIForFilters:filters];
}

#pragma mark - Property accessors

- (void)setLayerController:(CycArrayController *)layerController
{
    if (_layerController == layerController) {
        return;
    }
    
    _layerController = layerController;
    
    [_layerController addObserver:self
                       forKeyPath:@"selectionIndex"
                          options:NSKeyValueObservingOptionNew
                          context:&selectionIndexContext];
    
    NSArray *selectedLayers = [_layerController selectedObjects];
    if (selectedLayers == nil) {
        return;
    }
    
    VideoLayer *selectedLayer = selectedLayers[0];
    [self setupFilterController:[selectedLayer filterController]];
}

- (CycArrayController *)layerController
{
    return _layerController;
}

@end
