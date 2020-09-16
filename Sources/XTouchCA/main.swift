//
//  main.swift
//
//
//  Created by Kit Transue on 2020-09-10.
//

import CoreMIDI
import ControlSurface

do {
    do {
        let n = MIDIGetNumberOfExternalDevices()
        print("Devices present: \(n)")
        assert(n == 0)  // even with X-Touch present, not shown as an external device
    }
    
    do {
        let n = MIDIGetNumberOfSources()
        print("Sources present: \(n)")
        assert(n == 1)  // with X-Touch present
    }
    
    do {
        let n = MIDIGetNumberOfDestinations()
        print("Destinations present: \(n)")
        assert(n == 1)  // with X-Touch present
    }
}

do {
    var client = MIDIClientRef()
    let clientResult = MIDIClientCreate("MIDI subsystem client" as CFString, nil, nil, &client)
    guard clientResult == noErr else {
        fatalError("MIDIClientCreate error: \(clientResult)")
    }
    
    var inputPort = MIDIPortRef()
    let portResult = MIDIInputPortCreate(client, "input port" as CFString, midiEventCallback, nil, &inputPort)
    guard portResult == noErr else {
        fatalError("MIDIInputPortCreate error: \(portResult)")
    }
    
    let sourceEndpoint = MIDIGetSource(0)
    let bindResult = MIDIPortConnectSource(inputPort, sourceEndpoint, nil)
    guard bindResult == noErr else {
        fatalError("MIDIPortConnectSource error: \(bindResult)")
    }
    
    var outputPort = MIDIPortRef()
    let outputCreateResult = MIDIOutputPortCreate(client, "output port" as CFString, &outputPort)
    guard outputCreateResult == noErr else {
        fatalError("MIDIOutputPortCreate error: \(outputCreateResult)")
    }
    
    let sinkEndpoint = MIDIGetDestination(0)
    
    controlPort = outputPort
    controlEndpoint = sinkEndpoint
    
    print("Entering run loop")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
    print("Finished run loop")
}

var controlPort: MIDIPortRef? = nil
var controlEndpoint: MIDIEndpointRef? = nil

func midiEventCallback(_ packets: UnsafePointer<MIDIPacketList>, _ readProcRefCon: UnsafeMutableRawPointer?, _ srcConnRefCon: UnsafeMutableRawPointer?) {
    
    var value = 0
    for packet in packets.unsafeSequence() {
        let hex = packet.bytes().map {"0x" + String($0, radix:16)}
        print(hex.joined(separator: " "))
        value = Int(packet.bytes()[2])
    }
    
    if let controlPort = controlPort, let controlEndpoint = controlEndpoint {
        #if false
        // Layered mode: set 2 encoder to same value; 3 to its inverse
        let two = MidiMessage(subject: XTouchMini.setDialPositionMessage, id: 2, value: UInt8(value))
        let three = MidiMessage(subject: XTouchMini.setDialPositionMessage, id: 3, value: UInt8(127 - value))
        sendMidi(port: controlPort, dest: controlEndpoint, message: two)
        sendMidi(port: controlPort, dest: controlEndpoint, message: three)
        #else
        // Mackie mode: set 2 encoder to the value (fader most interesting)
        let two = MidiMessage(subject: MidiSubject.encoderChangeMC.rawValue,
                              id: 0x31, value: UInt8(value))
        sendMidi(port: controlPort, dest: controlEndpoint, message: two)
        #endif
    }
}

func sendMidi(port: MIDIPortRef, dest: MIDIEndpointRef, message: MidiMessage) {
    let midiNow: MIDITimeStamp = 0
    
    let builder = MIDIPacket.Builder(maximumNumberMIDIBytes: 3)
    print("sending message \(message.subject), \(message.id) value \(message.value)")
    builder.append(UInt8(message.subject), UInt8(message.id), UInt8(message.value))
    builder.timeStamp = /*bug in Builder.timeStamp signature*/ Int(midiNow)

    builder.withUnsafePointer { packet in
        var list = MIDIPacketList()
        list.numPackets = 1
        list.packet = packet.pointee
        MIDISend(port, dest, &list)
    }
}
