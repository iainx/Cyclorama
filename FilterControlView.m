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
    
    _filterViews = [[NSMutableArray alloc] init];
    return self;
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

#pragma mark - Constraints

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(250.0, 250.0);
}

#pragma mark - Filter controls

static int selectionIndexContext;

- (void)filterAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    ActorFilter *af = userInfo[@"object"];
    NSNumber *index = userInfo[@"index"];

    FilterView *newView = [[FilterView alloc] initWithFilter:af];
    NSPoint insertPoint;

    if ([_filterViews count] > 0) {
        FilterView *view = _filterViews[[index unsignedIntegerValue]];

        insertPoint = [view frame].origin;

        for (NSUInteger i = [index unsignedIntegerValue]; i < [_filterViews count]; i++) {
            // Move all these views up
        }
    } else {
        insertPoint = NSMakePoint(5.0, 5.0);
    }

    [_filterViews insertObject:newView atIndex:[index unsignedIntegerValue]];
    
    NSRect viewBounds = [newView bounds];
    viewBounds.origin = insertPoint;
    viewBounds.size.height = [self bounds].size.height - 10.0;
    
    [newView setFrame:viewBounds];
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
        // FIXME: Do stuff
    }
    
    for (ActorFilter *af in filters) {
        FilterView *view = [[FilterView alloc] initWithFilter:af];
        
        NSLog(@"Hello! %@", [af filterName]);
        // Set position
        [view setFrameOrigin:NSMakePoint(5.0, 5.0)];
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

    NSLog(@"Setting up filter controller");

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
