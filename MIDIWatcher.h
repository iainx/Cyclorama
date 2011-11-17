//
//  MIDIWatcher.h
//  Flare
//
//  Created by iain on 07/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@interface MIDIWatcher : NSObject {
@private
    MIDIClientRef midiClient;
    MIDIEndpointRef endPoint;
    MIDIPortRef inputPort;
}

@end
