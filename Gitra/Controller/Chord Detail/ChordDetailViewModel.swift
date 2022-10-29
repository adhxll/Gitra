//
//  ChordDetailViewModel.swift
//  Gitra
//
//  Created by Samuel Maynard on 11/04/22.
//

import UIKit
import Speech
import AVFoundation
import Lottie
import Foundation
import Combine

class ChordDetailViewModel{
    var countFinger = 0
    var strings = [0,0,0,0,0,0] //0 is open and -1 is dead
    var fingering = [0,0,0,0,0,0] //-1 means no fingers are there
    var labelForAccessibility = ["","","","","",""]
    var startingFret = 100 //initialize max value to compare
    
    @Published var currString = -1
    @Published var alertMessage = ""
    @Published var lblCommandText = ""
    @Published var lblCommandTextLowerCased = ""
    @Published var task: SFSpeechRecognitionTask!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    let speaker = Speaker()

    //Timer
    var timer: Timer?
    
    //
    func prepareAudioEngine(){
        print("Starting audio recognition")
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()
        guard request == request else {
            fatalError("Unable to Create SFSpeech Object")
        }
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error Starting Audio Listener!")
            alertMessage = "Error Start Audio Listener"
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            alertMessage = "Recognization is now allowed on your local"
            print("Recognization is now allowed on your local")
            return
        }
        
        if !myRecognization.isAvailable {
            print("Recognization is not available!")
            alertMessage = "Recognization is not available"
        }
        var isFinal = false
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            print("Speech Recornizer is working!")
            print("Task Result : \(result ?? SFSpeechRecognitionResult())")
            if let result = result {
                print("Result = Result")
                let resultCommand = result.bestTranscription.formattedString
                // Should I compare the result here to see if it changed?
                self.lblCommandText = resultCommand
                isFinal = result.isFinal
                
            }
            else if result == nil {
                print("Result is nil")
            }
            if isFinal {
                print("Done recognizing speech")
            } else if error == nil {
                print("Error = Nil")
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                    // Do whatever needs to be done when the timer expires
                    self.cancelSpeechRecognitization(resultCommand: self.lblCommandText)
                })
            }
        })
        
        if (task.isFinishing == true) {
            print("Lowercased Label Command Text : \(lblCommandTextLowerCased)")
            lblCommandTextLowerCased = self.lblCommandText.lowercased()
            
            if (lblCommandTextLowerCased == "next") {
                print("Next")
            }
        }
    }
    
    func cancelSpeechRecognitization(resultCommand: String) {
        if (task != nil) {
            task!.finish()
            task!.cancel()
            task = nil
            lblCommandTextLowerCased = resultCommand.lowercased()
        }
    }
    
    func changeString(isNext: Int){
        if isNext == 1 {
            currString = (currString + 1) % 6
            
            if (currString == 5) {
            }
            
        } else if isNext == 2 {
            currString = (currString - 1)
            if currString < 0{
                currString = 5
            }
        } else if isNext == 3 {}
    }
    
    func currentNote(_ senar: Int) -> String {
        let fret = strings[5-senar]
        if fret >= 0 {
            return Database.shared.getGuitarNote(senar, strings[(5 - senar)])
        }
        return ""
    }
    
    func generateStringForLabel(){ //Jari, Senar, Fret
        var j = 5
        for i in (0...5){
            labelForAccessibility[i] = guitarString((i+1)) + " String, "
            if strings[j] == -1{
                labelForAccessibility[i] += "muted."
            }
            else{
                if strings[j] == 0{
                    labelForAccessibility[i] += "open string. "
                }
                else if strings[j] > 0{
                    labelForAccessibility[i] += guitarFingering((fingering[j])) + " on "
                    labelForAccessibility[i] += "fret " + String(strings[j]) + ". "
                }
            }
            j-=1
            
        }
    }
    
    //function to translate the strings from API into arrays (the 'strings' and 'fingering' array
    //it also determine the starting fret and how many indicator(s) are present in the diagram
    func translateToCoordinate(chord:ChordModel){
        guard let s = chord.strings else {return}
        let stringsComponents = s.split{ $0.isWhitespace }.map { String($0) }
        guard let f = chord.fingering else {return}
        let fingeringComponents = f.split{ $0.isWhitespace }.map { String($0) }
        
        for i in 0..<stringsComponents.count{
            if stringsComponents[i] != "X"{
                let fret = Int(stringsComponents[i])!
                
                strings[i] = fret
                if(fret < startingFret && fret > 0){ //this determines the starting point by assesing the minimal fret value
                    startingFret = fret
                }
                if(fret>0){ //counting which indicator is going to be present
                    countFinger += 1
                }
            }else{ //if the component is X
                strings[i] = -1
            }
            
            if fingeringComponents[i] != "X"{
                fingering[i] = Int(fingeringComponents[i])!
            }else{ //if the component is X
                fingering[i] = -1
            }
        }
        
        if startingFret <= 2{
            startingFret = 1
        }
    }
    
    func guitarFingering(_ finger: Int) -> String {
        switch finger {
        case 1 :
            return "index finger"
        case 2 :
            return "middle finger"
        case 3 :
            return "ring finger"
        case 4 :
            return "pinky finger"
        default:
            return ""
        }
    }

    func guitarString(_ index: Int) -> String {
        switch index {
        case 1 :
            return "1st"
        case 2 :
            return "2nd"
        case 3 :
            return "3rd"
        default :
            return "\(index)th"
        }
    }
    
}




