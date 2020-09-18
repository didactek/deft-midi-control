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

    for c in surface.encoders.shuffled() {
        c.value = c.value.changed(to: 11)
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.1))
    }
    for c in (surface.topRowButtons + surface.bottomRowButtons).shuffled() {
        c.selected = true
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.bottomRowButtons.reversed() {
        c.selected = false
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.topRowButtons {
        c.selected = false
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.encoders.reversed() {
        for i in 0 ... 10 {
            c.value = c.value.changed(to: 11 - i)
            Thread.sleep(until: Date(timeIntervalSinceNow: 0.005))
        }
    }

    let dialThreeSubscription = surface.encoders[2].$value.sink { print("encoder 3:", $0.normalized()) }
    
    print("Entering run loop")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
    print("Finished run loop")
}
