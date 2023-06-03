# swift-midi-control

swift-midi-control provides support for working with MIDI devices in Swift
using a Combine pattern. It includes a MCSurface library for working with
Mackie Control compatible surface controllers.

swift-midi-control includes:

- MIDICombine: a Swift Combine-driven MIDI library to abstract CoreMIDI
- MCSurface: a model of Mackie Control surface controls and indicators
- XTouchMiniMC: a configuration to model the Behringer XTouch Mini in Mackie Control emulation mode
- XTMMCExample: a sample application illustrating use of XTouchMiniMC


## MIDICombine

MIDICombine is a Swift-friendly wrapper to CoreMIDI with a focus on
exchanging messages with a single device.


## XTouchMiniMC

XTouchMiniMC is an interface to an X-Touch Mini in Mackie Control mode.

When the user operates the surface, actions from the top/bottom row buttons,
layer buttons, rotary encoders (both twist and click), and the
fader are published as Combine events.

Button indicators can be set to on, off, or blink. The arc of indicators
that surround each rotary encoder can each be independently configured
to the display modes supported by the device.

Example that matches button illumination with button pressed state:

```
import XTouchMiniMC

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
