//
//  MidiEndpoint.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation
import CoreMIDI

class MidiEndpoint {
    let controlPort: MIDIPortRef
    let controlEndpoint: MIDIEndpointRef
    
    init(port: MIDIPortRef, endpoint: MIDIPortRef) {
        controlPort = port
        controlEndpoint = endpoint
    }

    func sendMidi(message: MidiMessage?) {
        guard let message = message else {
            return
        }
        logger.trace("sendMidi message: subject: \(message.subject) id: \(message.id) value: \(message.value)")
        
        let midiNow: MIDITimeStamp = 0
        
        let builder = MIDIPacket.Builder(maximumNumberMIDIBytes: 3)
        builder.append(message.subject.rawValue, message.id, message.value)
        builder.timeStamp = /*bug in Builder.timeStamp signature*/ Int(midiNow)
        
        builder.withUnsafePointer { packet in
            var list = MIDIPacketList()
            list.numPackets = 1
            list.packet = packet.pointee
            MIDISend(controlPort, controlEndpoint, &list)
        }
    }
}