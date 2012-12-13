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

@implementation FilterControlView

@synthesize layerController = _layerController;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] set];
    NSRectFill([self bounds]);
}

- (void)setUIForFilters:(NSArray *)filters
{
    NSLog(@"Setting filters");
}

static int selectionIndexContext;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &selectionIndexContext) {
        VideoLayer *selectedLayer = [_layerController selectedObjects][0];
        NSArray *filters = [selectedLayer actorFilters];
        
        [self setUIForFilters:filters];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

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
    NSArray *filters = [selectedLayer actorFilters];
    
    [self setUIForFilters:filters];
}

- (CycArrayController *)layerController
{
    return _layerController;
}

@end
