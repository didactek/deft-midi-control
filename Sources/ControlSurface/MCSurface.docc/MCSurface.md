# ``MCSurface``

MCSurface provides a model of Mackie control surface controls and
indicators, with tools to convert back and forth to MIDI messages.

## Overview

MCSurface adds semantics to working with the controls and indicators
provided by a Mackie-compatible MIDI controller. Controls publish events
using Combine. Indicators have properties that when set send a MIDI message
to the control surface to change to the corresponding state.



## Topics

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

