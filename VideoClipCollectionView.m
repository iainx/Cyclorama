//
//  VideoClipCollectionView.m
//  Cyclorama
//
//  Created by Iain Holmes on 02/11/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import "VideoClipCollectionView.h"
#import "VideoClipCollectionItemView.h"

@implementation VideoClipCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
    NSCollectionViewItem *item = [super newItemForRepresentedObject:object];
    VideoClipCollectionItemView *view = (VideoClipCollectionItemView *)[item view];

    [view setClip:(VideoClip *)object];
    
    return item;
}

@end