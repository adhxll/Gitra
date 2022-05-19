//
//  AutomaticTunerViewModel.swift
//  Gitra
//
//  Created by Yahya Ayyash Asaduddin on 16/04/22.
//

import Foundation

protocol AutomaticTunerViewModelProtocol {
    func tunerDidMeasure(pitch: Float, amplitude: Float, target: Float, frame: Float)
}

protocol AutomaticTunerViewModelAction {
    func tunerResultMatch()
    func tunerResultClose()
    func tunerResultFar()
    func shouldUpdateLabel(with freqGap: Float)
    func updateIndicatorPosition(position: Float, difference: Float)
}

class AutomaticTunerViewModel {
    var delegate: AutomaticTunerViewModelProtocol?
    var action: AutomaticTunerViewModelAction?
    
    init() {
    }
    
    func map(minRange: Int, maxRange: Int, minDomain: Int, maxDomain: Int, value: Int) -> Float {
        return Float(minDomain + (maxDomain - minDomain) * (value - minRange) / (maxRange - minRange))
    }
}

extension AutomaticTunerViewModel: AutomaticTunerViewModelProtocol {
    func tunerDidMeasure(pitch: Float, amplitude: Float, target: Float, frame: Float) {
        let freqGap: Float = pitch - target
        let errorDiff: Float = target * 0.5
        var position: Float = 0.0
        
        if abs(freqGap) < errorDiff { // Target note is pretty close
            let mappedPos = map(minRange: Int(target - errorDiff), maxRange: Int(target + errorDiff), minDomain: Int(-frame), maxDomain: Int(frame), value: Int(pitch))
            position = mappedPos
            
            if abs(freqGap) < target * 0.005 {
                action?.tunerResultMatch()
            } else {
                action?.tunerResultClose()
                action?.shouldUpdateLabel(with: freqGap)
            }
        } else { // Target note is much lower or larger

            action?.tunerResultFar()
            action?.shouldUpdateLabel(with: freqGap)
            position = freqGap > 0 ? frame : -frame
        }
        
        let diff: Float = (round(100 * freqGap)) / 100
        action?.updateIndicatorPosition(position: position, difference: diff)

    }
}
