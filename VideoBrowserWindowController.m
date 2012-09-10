//
//  VideoBrowserWindowController.m
//  Cyclorama
//
//  Created by iain on 09/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoBrowserWindowController.h"
#import "VideoClipController.h"
#import "VideoClip.h"
#import "VideoBrowserCell.h"
#import "PXListView.h"

@implementation VideoBrowserWindowController
@synthesize clipController = _clipController;

- (id)init
{
    self = [super initWithWindowNibName:@"VideoBrowserWindowController"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [_listView reloadData];
}

- (void)setClipController:(VideoClipController *)clipController
{
    if (clipController == _clipController) {
        return;
    }
    
    _clipController = clipController;
    [_clipController addObserver:self
                      forKeyPath:@"arrangedObjects"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    
    [_listView reloadData];
}

- (VideoClipController *)clipController
{
    return _clipController;
}

#pragma mark - List delegates

- (NSUInteger)numberOfRowsInListView:(PXListView *)aListView
{
    NSArray *clips = [_clipController arrangedObjects];
    return [clips count];
}

- (PXListViewCell *)listView:(PXListView *)aListView
                  cellForRow:(NSUInteger)row
{
    VideoBrowserCell *cell = (VideoBrowserCell *)[aListView dequeueCellWithReusableIdentifier:@"VideoBrowserCell"];
    VideoClip *clip = [_clipController arrangedObjects][row];
    
    if (cell == nil) {
        cell = [VideoBrowserCell cellLoadedFromNibNamed:@"VideoBrowserCell"
                                     reusableIdentifier:@"VideoBrowserCell"];
    }
    
    [[cell title] setStringValue:[clip title]];
    [[cell details] setStringValue:@""];
    [[cell imageView] setImage:[clip thumbnail]];
    
    return cell;
}

- (CGFloat)listView:(PXListView *)aListView
        heightOfRow:(NSUInteger)row
{
    return 57.0;
}
@end
