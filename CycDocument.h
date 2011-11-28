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

@interface CycDocument : NSDocument <NSTableViewDelegate> {
@private
    NSMutableArray *layers;
    CycArrayController *layerController;
    
    NSMutableArray *filters;
    CycArrayController *filterController;
    
    StageView *stageView;
    NSCollectionView *videoClipCollectionView;
    
    NSMutableArray *videos;
    VideoClipController *videoClipController;
    
    IKFilterUIView *currentFilterView;
}

@property (readwrite, retain)NSMutableArray *filters;
@property (readwrite, retain)NSMutableArray *layers;
@property (readwrite, retain)IBOutlet CycArrayController *layerController;
@property (readwrite, retain)IBOutlet CycArrayController *filterController;
@property (readwrite, assign)IBOutlet NSTableView *filterTableView;
@property (readwrite, assign)IBOutlet NSBox *filterUIBox;

@property (readwrite, assign)IBOutlet StageView *stageView;
@property (readwrite, assign)IBOutlet NSCollectionView *videoClipCollectionView;
@property (readonly)IBOutlet NSMutableArray *videos;
@property (readwrite, retain)IBOutlet VideoClipController *videoClipController;

- (IBAction)openAddFilterSheet:(id)sender;

@end
