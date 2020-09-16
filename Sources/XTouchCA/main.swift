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
    let surface = XTouchMiniMC(sourceEndpoint: MIDIGetSource(0),
                               sinkEndpoint: MIDIGetDestination(0))
    
    print("Entering run loop")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
    print("Finished run loop")
}
