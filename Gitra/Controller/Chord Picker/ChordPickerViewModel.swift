//
//  ChordPickerViewModel.swift
//  Gitra
//
//  Created by Samuel Maynard on 09/05/22.
//

import Foundation

class ChordPickerViewModel{
    var note = Database.shared.getNote()
    var chord = Database.shared.getChord()
    var result = ChordName(title: "", accessibilityLabel: "", urlParameter: "")
    
    var root = ""
    var quality = ""
    var tension = ""
    
    func chooseChordValue(){
        var input = root + "_" + quality + tension
        input = transformChordAPI(input)
        result.urlParameter = input
        result.title = result.title?.replacingOccurrences(of: "_", with: "")
    }
    
    func selectedChordLabel() -> String {
        return (transformChordAccessibility(root) +  " " + transformChordAccessibility(quality) +  " " + transformChordAccessibility(tension))
    }
    
    func transformChordAPI(_ input: String) -> String {
        var output = input
        output = output.lowercased()
        
        if output.contains("major") && output.contains("7") {
            output = output.replacingOccurrences(of: "major", with: "maj")
        } else {
            output = output.replacingOccurrences(of: "major", with: "")
        }
        
        if tension == "-" && (quality == "-" || quality == "major") {
            output = output.replacingOccurrences(of: "_", with: "")
        }
        
        output = output.replacingOccurrences(of: "♯", with: "#")
        output = output.replacingOccurrences(of: "♭", with: "b")
        output = output.replacingOccurrences(of: "-", with: "")
        output = output.replacingOccurrences(of: "/", with: "")
        output = output.replacingOccurrences(of: "minor", with: "m")
        output = output.trimmingCharacters(in: .whitespaces)
        output.capitalizeFirstLetter()
        
        result.title = output
        output = swappingSharp(output)
        
        return output
    }
    
    func transformChordAccessibility(_ input: String) -> String {
        var output = input
        output = output.replacingOccurrences(of: "♯", with: " Sharp")
        output = output.replacingOccurrences(of: "♭", with: " Flat")
        output = output.replacingOccurrences(of: "-", with: "")
        
        switch output {
        case "Dim":
            output = "Diminished"
        case "Sus":
            output = "Suspended"
        case "Aug":
            output = "Augmented"
        default:
            break
        }
        return output
    }
    
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
