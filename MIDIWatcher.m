//
//  MIDIWatcher.m
//  Flare
//
//  Created by iain on 07/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MIDIWatcher.h"


@implementation MIDIWatcher

NSString *const FlareMIDIMessageNotification = @"FlareMIDIMessageNotification";

static void
midiInputCallback (const MIDIPacketList *list,
                   void *procRef,
                   void *srcRef)
{
    @autoreleasepool {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        UInt16 nBytes;
        const MIDIPacket *packet = &list->packet[0];
        CycMIDIMessageType type;
        
        for (unsigned int i = 0; i < list->numPackets; i++) {
            UInt16 iByte, size;
            nBytes = packet->length;
            
            iByte = 0;
            while (iByte < nBytes) {
                unsigned char status = packet->data[iByte];
                if (status < 0xC0) {
                    size = 3;
                } else if (status < 0xE0) {
                    size = 2;
                } else if (status < 0xF0) {
                    size = 3;
                } else if (status == 0xF0) {
                    size = nBytes - iByte;
                } else if (status < 0xF3) {
                    size = 3;
                } else if (status == 0xF3) {
                    size = 2;
                } else {
                    size = 1;
                }
                
                int data1 = 0, data2 = 0, channel;
                type = kOtherMessage;
                
                channel = status & 0xF;
                switch (status & 0xF0) {
                    case 0x80:
                        type = kNoteOff;
                        data1 = packet->data[iByte + 1];
                        data2 = packet->data[iByte + 2];
                        break;
                        
                    case 0x90:
                        type = kNoteOn;
                        data1 = packet->data[iByte + 1];
                        data2 = packet->data[iByte + 2];
                        break;
                        
                    case 0xA0:
                        NSLog(@"Aftertouch: %d, %d", packet->data[iByte + 1], packet->data[iByte + 2]);
                        break;
                        
                    case 0xB0:
                        type = kControlChange;
                        data1 = packet->data[iByte + 1];
                        data2 = packet->data[iByte + 2];
                        break;
                        
                    case 0xC0:
                        NSLog(@"Program change: %d", packet->data[iByte + 1]);
                        type = kProgrammeChange;
                        data1 = packet->data[iByte + 1];
                        data2 = 0;
                        break;
                        
                    case 0xD0:
                        NSLog(@"Change aftertouch: %d", packet->data[iByte + 1]);
                        break;
                        
                    case 0xE0:
                        NSLog(@"Pitch wheel: %d, %d", packet->data[iByte + 1], packet->data[iByte + 2]);
                        break;
                        
                    default:
                        NSLog(@"Some other message");
                        break;
                        
                }
                
                NSDictionary *userInfo = 
                    @{@"type": [NSNumber numberWithInt:type],@"channel": @(channel), @"data1": [NSNumber numberWithChar:data1], @"data2": [NSNumber numberWithChar:data2]};
                [nc postNotificationName:FlareMIDIMessageNotification object:(__bridge id)(procRef) userInfo:userInfo];
                
                iByte += size;
            }
            
            packet = MIDIPacketNext(packet);
        }
    
    }
}

- (id)init
{
    self = [super init];
    
    MIDIObjectType foundObject;
    MIDIObjectFindByUniqueID(1759718006, &endPoint, &foundObject);
    
    OSStatus result;
    
    result = MIDIClientCreate(CFSTR("Cyclorama client"), NULL, NULL, &midiClient);
    if (result != noErr) {
        NSLog(@"Error creating MIDI client: %s - %s",
              GetMacOSStatusErrorString(result), 
              GetMacOSStatusCommentString(result));
        return nil;
    }
    
    result = MIDIInputPortCreate(midiClient, CFSTR("Input port"), 
                                 midiInputCallback, (__bridge void *)(self), &inputPort);
    if (result != noErr) {
        NSLog(@"Error creating MIDI port: %s - %s",
              GetMacOSStatusErrorString(result),
              GetMacOSStatusCommentString(result));
        return nil;
    }
    
    result = MIDIPortConnectSource(inputPort, endPoint, NULL);
    if (result != noErr) {
        NSLog(@"Error connecting MIDI port: %s - %s",
              GetMacOSStatusErrorString(result),
              GetMacOSStatusCommentString(result));
        return nil;
    }
    
    return self;
}


@end
