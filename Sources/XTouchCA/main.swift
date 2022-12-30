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
    let surface = try! XTouchMiniMC(sourceEndpoint: MIDIGetSource(0),
                               sinkEndpoint: MIDIGetDestination(0))

    // Little bit of boot animation of the controls:
    for c in surface.encoders.shuffled() {
        c.indicator = c.indicator.changed(to: 11)
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.1))
    }
    for c in (surface.topRowButtons + surface.bottomRowButtons).shuffled() {
        c.illuminated = true
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.bottomRowButtons.reversed() {
        c.illuminated = false
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.topRowButtons {
        c.illuminated = false
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.encoders.reversed() {
        for i in 0 ... 10 {
            c.indicator = c.indicator.changed(to: 11 - i)
            Thread.sleep(until: Date(timeIntervalSinceNow: 0.005))
        }
    }

    let faderSubscription = surface.fader.$value.sink { print("fader position:", $0.normalized()) }
    
    let toggleFeedback = surface.bottomRowButtons.map { button in
        button.$event.sink {
            switch $0 {
            case .pressed:
                button.illuminated = !button.illuminated
            case .released:
                break
            }
        }
    }
    
    let momentaryFeedback = surface.topRowButtons.map { button in
        button.$event.sink {
            switch $0 {
            case .pressed:
                button.illuminated = true
            case .released:
                button.illuminated = false
            }
        }
    }
    
    let rotaryFeedback = surface.encoders.map { encoder in
        encoder.$change.sink {
            encoder.indicator = encoder.indicator.adjusted(by: $0)
        }
    }
    
    print("Entering run loop")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
    print("Finished run loop")
}
