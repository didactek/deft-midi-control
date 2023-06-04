# ``MCSurface``

MCSurface provides a model of Mackie control surface controls and
indicators, with tools to convert back and forth to MIDI messages.

## Overview

MCSurface builds on MIDICombine to provide support for working with the
controls and indicators on a Mackie-compatible MIDI controller.
Controls publish events using Combine. Indicators have properties that when
set send a MIDI message to the control surface to change to the
corresponding state.


## XTouchMiniMC

``XTouchMiniMC`` is an object that models an XTouch Mini in Mackie Control mode.

XTouchMiniMC provides properties that represent the elements of the
controller. Addresses of each element are wired by the initializer:

- ``XTouchMiniMC/encoders``
- ``XTouchMiniMC/topRowButtons``
- ``XTouchMiniMC/bottomRowButtons``
- ``XTouchMiniMC/layerButtons``
- ``XTouchMiniMC/fader``

Elements publish events when the controller is operated. Where the controller
has indicators (LEDs), the element provides properties that when set will update
the feedback on the controller.



## Topics

### Pre-configured devices

- ``XTouchMiniMC``

### Device controls

- ``IndicatorButton``
- ``SurfaceRotaryEncoder``
- ``SurfaceFader``

### Indicator protocols

- ``BinaryIndicator``
- ``BlinkIndicator``
- ``MultiSegmentIndicator``

### Control feedback protocols

- ``DeltaEncoderProtocol``
- ``MomentaryButton``

