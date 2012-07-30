//
//  CycDocument.h
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CycArrayController;
@class StageView;
@class VideoClipController;
@class CycFilterUIView;

@interface CycDocument : NSDocument <NSTableViewDelegate> {
@private
    NSMutableArray *layers;
    CycArrayController *layerController;
    
    NSMutableArray *filters;
    CycArrayController *filterController;
    
    StageView *__weak stageView;
    NSCollectionView *__weak videoClipCollectionView;
    
    NSMutableArray * videos;
    VideoClipController *videoClipController;
    
    CycFilterUIView *currentFilterView;
}

@property (readwrite, strong)NSMutableArray *filters;
@property (readwrite, strong)NSMutableArray *layers;
@property (readwrite, strong)IBOutlet CycArrayController *layerController;
@property (readwrite, strong)IBOutlet CycArrayController *filterController;
@property (readwrite, weak)IBOutlet NSTableView *filterTableView;
@property (readwrite, weak)IBOutlet NSBox *filterUIBox;
@property (readwrite, weak)IBOutlet NSScrollView *filterScrollView;

@property (readwrite, weak)IBOutlet StageView *stageView;
@property (readwrite, weak)IBOutlet NSCollectionView *videoClipCollectionView;
@property (readonly, strong)IBOutlet NSMutableArray *videos;
@property (readwrite, strong)IBOutlet VideoClipController *videoClipController;

- (IBAction)openAddFilterSheet:(id)sender;

@end
