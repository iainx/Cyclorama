//
//  SharedTypes.h
//  Flare
//
//  Created by iain on 07/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

FOUNDATION_EXPORT NSString *const CycArrayControllerObjectAdded;
FOUNDATION_EXPORT NSString *const CycArrayControllerObjectRemoved;

FOUNDATION_EXPORT NSString * const CycFilterValueChangedNotification;
FOUNDATION_EXPORT NSString * const CycFilterPasteboardType;

typedef enum {
    kNoteOff,
    kNoteOn,
    kControlChange,
    kProgrammeChange,
    kOtherMessage
} CycMIDIMessageType;

