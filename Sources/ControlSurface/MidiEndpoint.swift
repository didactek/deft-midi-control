//
//  MidiEndpoint.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation
import CoreMIDI

protocol MidiEndpoint {
    var controlPort: MIDIPortRef { get }
    var controlEndpoint: MIDIEndpointRef { get }
    func sendMidi(message: MidiMessage?)
}

extension MidiEndpoint {
    func sendMidi(message: MidiMessage?) {
        guard let message = message else {
            return
        }
        let midiNow: MIDITimeStamp = 0
        
        let builder = MIDIPacket.Builder(maximumNumberMIDIBytes: 3)
        print("sending message \(message.subject), \(message.id) value \(message.value)")
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
