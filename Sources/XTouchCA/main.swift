//
//  main.swift
//
//
//  Created by Kit Transue on 2020-09-10.
//

import Foundation
import Combine
import XTouchMiniMC

#if false // true: show a little bit more of how MIDI works
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
#endif

do {
    let surface = try! XTouchMiniMC(midiSourceIndex: 0)

    // Little bit of boot animation of the controls:
    for c in surface.encoders.shuffled() {
        c.indicator = c.indicator.changed(to: 11)
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
            c.indicator = c.indicator.changed(to: 11 - i)
            Thread.sleep(until: Date(timeIntervalSinceNow: 0.005))
        }
    }

    var subscriptions = Set<AnyCancellable>()

    surface.fader.$value.sink {
        print("fader position:", $0.normalized())
    }
    .store(in: &subscriptions)

    // Toggle on press example implementation
    for button in surface.bottomRowButtons {
        button.isPressed.sink {
            if $0 {
                button.isIlluminated = !button.isIlluminated
            }
        }
        .store(in: &subscriptions)
    }
    
    // Momentary example implementation
    for button in surface.topRowButtons {
        button.isPressed.sink {
            button.isIlluminated = $0
        }
        .store(in: &subscriptions)
    }

    // Use changes in encoder position to change level indicators
    for encoder in surface.encoders {
        encoder.change.sink {
            encoder.indicator = encoder.indicator.adjusted(by: $0)
        }
        .store(in: &subscriptions)
    }
    
    for button in surface.layerButtons {
        button.isPressed.sink {
            if $0 {
                button.blink = button.blink == .off ? .blink : .off
            }
        }
        .store(in: &subscriptions)
    }
    
    
    print("Entering run loop")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 10))
    print("Finished run loop")
    subscriptions.removeAll()
}
