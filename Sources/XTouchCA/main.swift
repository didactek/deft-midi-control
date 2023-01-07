//
//  main.swift
//
//
//  Created by Kit Transue on 2020-09-10.
//

import CoreMIDI
import ControlSurface
import Combine

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
    let surface = try! XTouchMiniMC(midiSourceIndex: 0)

    // Little bit of boot animation of the controls:
    for c in surface.encoders.shuffled() {
        c.indicator.indicator = c.indicator.indicator.changed(to: 11)
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.1))
    }
    for c in (surface.topRowButtons + surface.bottomRowButtons).shuffled() {
        c.isIlluminated = true
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.bottomRowButtons.reversed() {
        c.isIlluminated = false
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.topRowButtons {
        c.isIlluminated = false
        Thread.sleep(until: Date(timeIntervalSinceNow: 0.05))
    }
    for c in surface.encoders.reversed() {
        for i in 0 ... 10 {
            c.indicator.indicator = c.indicator.indicator.changed(to: 11 - i)
            Thread.sleep(until: Date(timeIntervalSinceNow: 0.005))
        }
    }

    var subscriptions: [AnyCancellable] = []
    subscriptions.append(surface.fader.$value.sink { print("fader position:", $0.normalized()) })

    // Toggle on press example
    subscriptions.append(contentsOf: surface.bottomRowButtons.map { button in
        button.$isPressed.sink {
            if $0 {
                button.isIlluminated = !button.isIlluminated
            }
        }
    })

    // Momentary example
    subscriptions.append(contentsOf: surface.topRowButtons.map { button in
        button.$isPressed.sink {
            button.isIlluminated = $0
        }
    })
    
    subscriptions.append(contentsOf: surface.encoders.map { encoder in
        encoder.delta.$change.sink {
            encoder.indicator.indicator = encoder.indicator.indicator.adjusted(by: $0)
        }
    })
    
    subscriptions.append(contentsOf: surface.layerButtons.map { button in
        button.$isPressed.sink {
            if $0 {
                button.blink = button.blink == .off ? .blink : .off
            }
        }
    })
    
    print("Entering run loop")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
    print("Finished run loop")
    subscriptions = []
}
