//
//  SLFCloseButtonCell.h
//  Cyclorama
//
//  Created by iain on 08/01/2013.
//  Copyright (c) 2013 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SLFCloseButtonCell : NSButtonCell

typedef enum {
    SLFButtonCellTypeOpen,
    SLFButtonCellTypeClose,
    SLFButtonCellTypeMaximise,
    SLFButtonCellTypeMinimise
} SLFButtonCellType;

@property (readwrite) SLFButtonCellType type;

@end