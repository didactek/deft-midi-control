# swift-midi-control

swift-midi-control provides support for working with MIDI devices in Swift
using a Combine pattern. It includes a MCSurface library for working with
Mackie Control compatible surface controllers.

swift-midi-control comprises:

- MIDICombine: a Swift Combine-driven MIDI library to abstract CoreMIDI
- MCSurface: a model of Mackie Control surface controls and indicators
- XTMMCExample: a sample application illustrating use of XTouchMiniMC

MCSurface includes XTouchMiniMC, a configuration that models the
Behringer X-Touch Mini in Mackie Control emulation mode.


## MIDICombine

MIDICombine is a Swift-friendly wrapper to CoreMIDI with a focus on
exchanging messages with a single device.

## MCSurface

MCSurface provides a model of Mackie control surface controls and
indicators, with tools to convert back and forth to MIDI messages.

### XTouchMiniMC

XTouchMiniMC is an interface to an X-Touch Mini in Mackie Control mode.

When the user operates the surface, actions from the top/bottom row buttons,
layer buttons, rotary encoders (both twist and click), and the
fader are published as Combine events.

Button indicators can be set to on, off, or blink. The arc of indicators
that surround each rotary encoder can each be independently configured
to the display modes supported by the device.

Example that matches button illumination with button pressed state:

```swift
import MCSurface

let surface = try! XTouchMiniMC(midiSourceIndex: 0)

var subscriptions = Set<AnyCancellable>()

// Momentary example implementation
for button in surface.topRowButtons {
    button.isPressed.sink {
        button.isIlluminated = $0
    }
    .store(in: &subscriptions)
}
```

## Documentation

- [DocC for MCSurface](https://didactek.github.io/swift-midi-control/MCSurface/documentation/mcsurface)
- [DocC for MIDICombine](https://didactek.github.io/swift-midi-control/MIDICombine/documentation/midicombine)
- [DocC for XTMMCExample](https://didactek.github.io/swift-midi-control/XTMMCExample/documentation/xtmmcexample)
