//
//  SharedTypes.h
//  Flare
//
//  Created by iain on 07/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

extern NSString * const FlareMIDIMessageNotification;
extern NSString * const FlareVideoClipType;
extern NSString * const FlareVideoClipArrayType;

typedef enum {
    kNoteOff,
    kNoteOn,
    kControlChange,
    kProgrammeChange,
    kOtherMessage
} MIDIMessageType;

