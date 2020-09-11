//
//  main.swift
//
//
//  Created by Kit Transue on 2020-09-10.
//

import CoreMIDI

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
    
    print("Entering run loop")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
    print("Finished run loop")
}

func midiEventCallback(_ packets: UnsafePointer<MIDIPacketList>, _ readProcRefCon: UnsafeMutableRawPointer?, _ srcConnRefCon: UnsafeMutableRawPointer?) {
    print("callback!")
}
