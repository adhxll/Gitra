//
//  Helper.swift
//  Gitra
//
//  Created by Christopher Teddy  on 10/06/21.
//

import Foundation
import UIKit

struct ChordName {
    var title: String?
    var accessibilityLabel: String?
    var urlParameter: String?
}

class Helper {
    
    let roots = ["C": ["c", "sea", "she", "see"],
                 "D": ["d", "the", "t"],
                 "E": ["e"],
                 "F": ["f", "have", "if"],
                 "G": ["g"],
                 "A": ["a"],
                 "B": ["b", "bee", "be"]]
    let symbols = ["b": ["flat", "b", "♭"],
                   "#": ["sharp", "#", "♯", "shark", "shack", "shirt"]]
    let qualities = ["maj": ["major", "maj", "ranger"],
                     "m": ["minor", "min"],
                     "add": ["add"],
                     "aug": ["augmented", "aug"],
                     "dim": ["diminished", "dim"],
                     "sus": ["suspended", "sus"]]
    let tensions = [2: ["2", "two"],
                    4: ["4", "four"],
                    5: ["5", "five", "fifth"],
                    6: ["6", "six", "sixth"],
                    7: ["7", "seven", "seventh"],
                    9: ["9", "nine", "ninth"],
                    11: ["11", "eleven"],
                    13: ["13", "thirteen"]]
    
    func convertStringToParam(chord: String) -> ChordName {
        
        var outputChord = ChordName(title: "", accessibilityLabel: "", urlParameter: "")
        var outputTitle = ""
        var outputAccessibility = ""
        var output = chord.lowercased()
        output = output.replacingOccurrences(of: "-", with: " ")
        
        //Split the String
        //Example string a = "D sharp major seven" -> "D", "sharp", "major", "seven"
        let splitChordInput = output.split {
            $0.isWhitespace
        }.map {
            String($0)
        }
        //Take the first index value
        output = checkRoot(splitChordInput[0])
        outputTitle = output
        outputAccessibility = output
        
        //Determine chord root
        func checkRoot(_ text: String) -> String {
            for (notation, root) in roots {
                for char in root {
                    if text == char {
                        return notation
                    }
                }
            }
            return ""
        }
        
        //Determine sharp & flat
        func checkPitch(_ text: String) -> (String, String) {
            for (notation, symbol) in symbols {
                for char in symbol {
                    if text.contains(char) {
                        return (notation, (" " + symbol[0]))
                    }
                }
            }
            return ("","")
        }
        
        //Determine chord quality
        func checkQuality(_ text: String) -> (String, String) {
            for (notation, quality) in qualities {
                for char in quality {
                    if text.contains(char) {
                        return (notation, (" " + quality[0]))
                    }
                }
            }
            return ("","")
        }
        
        //Determine chord tension
        func checkTension(_ text: String) -> String {
            for (number, tension) in tensions {
                for char in tension {
                    if text.contains(char) {
                        return "\(number)"
                    }
                }
            }
            return ""
        }
        
        //Swapping sharp with flat chord
        func swappingSharp(_ text: String) -> (String, String) {
            switch text {
            case "C#" :
                return ("Db", "C sharp")
            case "D#" :
                return ("Eb", "D sharp")
            case "F#" :
                return ("Gb", "F Sharp")
            case "G#" :
                return ("Ab", "G sharp")
            case "A#" :
                return ("Bb", "A sharp")
            default :
                return (text, text)
            }
        }
        
        //Merging input
        for (index, text) in splitChordInput.enumerated() where index > 0 {
            
            let pitch = checkPitch(text)
            let quality = checkQuality(text)
            let tension = checkTension(text)
            
            //Check if the second word is # or flat
            if index == 1 && (pitch.0 != "") {
                output.append(pitch.0)
                
                outputAccessibility = output
                outputTitle = output
                
                output = swappingSharp(output).0
                outputAccessibility = swappingSharp(outputAccessibility).1
                
                output.append("_")
                continue
            } else if index == 1 && (pitch.0 == "") {
                output.append("_")
            } else if (index == 1 || index == 2) && quality.0 == "major" {
                output.append("maj")
                outputAccessibility.append("major")
            }
            
            output.append(quality.0)
            outputTitle.append(quality.0)
            outputAccessibility.append(quality.1)
            
            output.append(pitch.0)
            outputTitle.append(pitch.0)
            outputAccessibility.append(pitch.1)
            
            output.append(tension)
            outputTitle.append(tension)
            outputAccessibility.append(tension)
            
        }
        
        if output.contains("maj") && !output.contains("maj7") && (output.count == 5 || output.count == 6) {
            output.removeLast(4)
        }
        
        output.capitalizeFirstLetter()
        
        if (output.count > 0) && (Array(output)[0] == "_") {
            return ChordName(title: "", accessibilityLabel: "", urlParameter: "")
        }
        
        outputChord.title = outputTitle.replacingOccurrences(of: "_", with: "")
        outputChord.accessibilityLabel = outputAccessibility
        outputChord.urlParameter = output
        
//        print("Title:", outputChord.title!, "Label:", outputChord.accessibilityLabel!, "URL :", outputChord.urlParameter!)
        return outputChord
    }
}

// MARK: - UIKit Extension
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Array {
    func stringToBullets() -> NSAttributedString {
        let strArr = self.map( { "\($0)" })
        let joiner = "\n"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.firstLineHeadIndent = 0
        
        let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let bulletListString = strArr.joined(separator: joiner)
        return NSAttributedString(string: bulletListString, attributes: attributes)
    }
}

extension Bundle {
    public var appName: String { getInfo("CFBundleName") }
    public var displayName: String { getInfo("CFBundleDisplayName") }
    public var language: String { getInfo("CFBundleDevelopmentRegion") }
    public var identifier: String { getInfo("CFBundleIdentifier") }
    public var copyright: String { getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }
    
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "Not found." }
}
