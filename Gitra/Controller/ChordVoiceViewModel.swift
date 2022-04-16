//
//  ChordVoiceViewModel.swift
//  Gitra
//
//  Created by Adhella Subalie on 02/04/22.
//

import Foundation
import UIKit
import AVFoundation
import Speech
import Combine

class ChordVoiceViewModel {
    //Audio
    private var player: AVAudioPlayer?
    private var audioEngine = AVAudioEngine()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var task: SFSpeechRecognitionTask!
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    
    //Timer
    var timer: Timer?
    
    var chordNameModel = ChordName()
    @Published var chordResult = ""
    @Published var chordFound = false
    @Published var alertMessage = ""
    @Published var isRecognizingSpeech = false
    
    deinit {
        killAudioEngine()
    }
    
    func utter(text: String){
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechSynthesizer.speak(speechUtterance)
    }
    
    func playSpeechRecognitionSoundIndicator() {
        guard let url = Bundle.main.path(forResource: "siri", ofType: "m4a") else {
            print("URL not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
            //try audioSession.setMode(AVAudioSessionModeMeasurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
            let backgroundMusic = NSURL(fileURLWithPath: url)
            
            player = try AVAudioPlayer(contentsOf: backgroundMusic as URL, fileTypeHint: AVFileType.m4a.rawValue)
            guard let player = player else {return}
            player.play()
            
        } catch let error {
            print("Error ", error.localizedDescription)
        }
    }
    
    func deactivateSpeechRecognitization() {
        isRecognizingSpeech = false
        if ( task != nil) {
            task.finish()
            task.cancel()
            task = nil
            
            //Call the API
            chordNameModel = Helper().convertStringToParam(chord: chordResult)
            guard let chordURLParameterSave = chordNameModel.urlParameter else {
                return
            }
            
            //For Checking But Duplicate
            DispatchQueue.global().async {
                self.task = nil
                NetworkManager().getSpecificChord(chord: chordURLParameterSave) { chordResult in
                    DispatchQueue.main.async {
                        self.chordFound = true
                    }
                } completionFailed: { isFailed in
                    if ( isFailed == true) {
                        let textFailed = "Chord not found, please input again"
                        self.chordFound = false
                        self.utter(text: textFailed)
                        // Re-call
                        DispatchQueue.main.async {
                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                                // Do whatever needs to be done when the timer expires
                                self.activateSpeechRecognition(utter: self.chordResult)
                            })
                        }
                    }
                }
            }
        }
        killAudioEngine()
    }
    
    func activateSpeechRecognition(utter text:String) {
        isRecognizingSpeech = true
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
            alertMessage = "Error Start Audio Listener"
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            alertMessage = "Recognization is now allowed on your local"
            return
        }
        
        if !myRecognization.isAvailable {
            alertMessage =  "Recognization is not available"
        }
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            var isFinal = false
            
            if let result = result {
                self.chordResult = result.bestTranscription.formattedString
                // Should I compare the result here to see if it changed?
                isFinal = result.isFinal
            }
            
            if isFinal {
                //  self.cancelSpeechRecognitization()
                //                self.restartSpeechTimer()
                //                print("ISFinal")
            }
            else if error == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false, block: { (timer) in
                    // Do whatever needs to be done when the timer expires
                    self.deactivateSpeechRecognitization()
                })
            }
        })
        
        if ( task.isFinishing == true) {
            print("task is Finishing???? \(text)")
            let t = text
            let _ = t.split {
                $0.isWhitespace
            }.map {
                String($0)
            }
            print("the result \(t)")
        }
    }
    
    func killAudioEngine() {
//        isRecognizingSpeech = false
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
}
