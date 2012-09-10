//
//  VideoBrowswerCell.h
//  Cyclorama
//
//  Created by iain on 10/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "PXListViewCell.h"

@class VideoClip;
@interface VideoBrowserCell : PXListViewCell

@property (readwrite, weak) IBOutlet NSTextField *title;
@property (readwrite, weak) IBOutlet NSTextField *details;
@property (readwrite, weak) IBOutlet NSImageView *imageView;
@property (readwrite, strong) VideoClip *clip;

@end
