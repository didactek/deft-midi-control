# XTouchCA

This includes:
- MIDICombine: a Swift Combine-driven MIDI library to abstract CoreMIDI
- MCSurface: a model of Mackie control surface controls and indicators
- a configuration to model the Behringer XTouch Mini in Mackie Control emulation mode
- a sample application illustrating use of 


## FIXME

- rename: MIDIControlSurface? SwiftMIDISurface? Lowercase with hyphens:
  - swift-midi-control ("surface" implied; can factor out surface later if desired?)
- ControlSurface -> MCSurface?
- separate MContrrols from XT-specifics
- Document
- address LoD violations in SurfaceRotaryEncoder

## API

Indicators do not publish state: they are not expected to be a source of truth.

