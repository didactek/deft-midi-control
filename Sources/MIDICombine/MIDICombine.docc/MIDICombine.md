# ``MIDICombine``

A Swift Combine-driven MIDI library to abstract CoreMIDI.

## Overview

MIDICombine wraps the system CoreMIDI and translates system callbacks
into a stream of ``MidiMessage``s published by a ``MidiPublisher``.

The ``MidiCombine`` structure coordinates setting up the various endpoints
needed to communicate via MIDI. Its public members include an endpoint
for sending messages and a publisher for subscribing to incoming messages.


## sourceIndex limitation

This library does not provide support for enumerating or discovering
which devices are attached (or were recently attached) to the system,
or their capabilities.

The developer must provide the appropriate sourceIndex when constructing
a ``MidiCombine``. If only one device is attached, "0" is likely the 
index you want to use. The Developer Documentation for MIDIGetDevice()
provides some hints about iterating through attached devices to find
particular ones of interest.

### Possible iteration technique

Perhaps you iterate over devices using MIDIDeviceRef obtained from
MIDIGetDevice(Int), then over its entities using
MIDIDeviceGetEntity(MIDIDeviceRef, Int).

See the Developer Documentation for:

- MIDIObjectGetIntegerProperty(_:_:_:) 
- MIDI Object Properties (kMIDIPropertyName and others).

## Topics

### Setup

- ``MidiCombine``

### Messagess

- ``MidiMessage``

### Events

- ``MidiPublisher``
