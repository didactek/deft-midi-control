# XTouchCA

Access the Behringer XTouch Mini MIDI controller using Core MIDI.


## API Changes

### Setting values

Need to introduce a paradigm for setting values programmatically. The current
pattern is that observers can watch the value and get notification when it changes.

I experience a feedback loop when trying to have fader indicators reflect a status
that can be controlled either with a fader encoder or from the program internally:

- the application monitors the unified fader and adjusts program state on fader change
- the application pushes program state to the fader

In this wiring, operating the fader results in a loop:
- knob action updates fader position
- fader position published to application
- application adjusts state
- state change triggers post to update fader
- new fader position published to application
etc.




