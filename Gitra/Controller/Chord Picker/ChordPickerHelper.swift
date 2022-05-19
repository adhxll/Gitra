//
//  ChordPickerHelper.swift
//  Gitra
//
//  Created by Yahya Ayyash Asaduddin on 16/04/22.
//

import Foundation

class ChordPickerHelper {
    // The API only support flat chord, however we used sharp chord in the picker since it's more common
    // Thus before API call, we need to convert the sharp code to it's flat counterpart
    func swappingSharp(_ text: String) -> String {
        var output = text
        
        output = output.replacingOccurrences(of: "C#", with: "Db")
        output = output.replacingOccurrences(of: "D#", with: "Eb")
        output = output.replacingOccurrences(of: "F#", with: "Gb")
        output = output.replacingOccurrences(of: "G#", with: "Ab")
        output = output.replacingOccurrences(of: "A#", with: "Bb")
        
        return output
    }
}
