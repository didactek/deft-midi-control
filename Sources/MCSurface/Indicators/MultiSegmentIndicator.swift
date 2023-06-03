//
//  MultiSegmentIndicator.swift
//  
//
//  Created by Kit Transue on 2023-01-08.
//  Copyright © 2023 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//


/// Behavior of multi-segment indicators
public enum MultiSegmentIndicatorMode {
    /// A single llit element indicates the position.
    case singleTick
    /// Multiple elements are lit , starting from the left and going to the indicated position.
    case fromLeft
    /// Multiple elements are lit , starting from the center and filling left or right to the indicated position.
    case fromCenter
    ///  Multiple elements are lit , starting from the center and filling outwards in both directions.
    case mirror
}

public protocol MultiSegmentIndicator {
    /// Behaviour of lighting sequence
    var mode: MultiSegmentIndicatorMode { get set }
    
    /// Map for converting underlying range/position to the display elements.
    var indicator: ControlValue { get set }
}
