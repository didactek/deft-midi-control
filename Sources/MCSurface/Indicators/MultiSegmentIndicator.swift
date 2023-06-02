//
//  MultiSegmentIndicator.swift
//  
//
//  Created by Kit Transue on 2023-01-08.
//


public enum MultiSegmentIndicatorMode {
    case singleTick
    case fromLeft
    case fromCenter
    case mirror
}

public protocol MultiSegmentIndicator {
    var mode: MultiSegmentIndicatorMode { get set }
    var indicator: ControlValue { get set }
}
