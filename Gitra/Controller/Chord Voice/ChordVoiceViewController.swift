//
//  ChordVoiceViewController.swift
//  Gitra
//
//  Created by Christopher Teddy  on 07/06/21.
//

import UIKit
import Speech
import Lottie
import AVFoundation

class ChordVoiceViewController: UIViewController {
    
    @IBOutlet weak var textLogo: UIImageView!
    @IBOutlet weak var imageTap: UIImageView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblWhich: UILabel!
    
    //MARK: - Local Properties
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isStart: Bool = false
    let animationView = AnimationView()
    let defaults = UserDefaults.standard
    
    //Audio
    var player: AVAudioPlayer?
    
    //Timer
    var timer: Timer?
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("Error")
        }
        
        self.tabBarController?.tabBar.isHidden = false
        
        lblResult.text = "Say Something..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        self.extendedLayoutIncludesOpaqueBars = false
        self.tabBarController?.tabBar.isHidden = false
//        checkDefault()
        
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageTap.isUserInteractionEnabled = true
        imageTap.addGestureRecognizer(tapGestureRecognizer)
        
        requestPermission()
        
        textLogo.isAccessibilityElement = true
        textLogo.accessibilityHint = "Which chord do you want to play? Please tap twice the The Guitar Image Below. Please wait the Siri Voice done, then input the chord by your voice, and wait 5 second to know the feedback chord"
        
        imageTap.isAccessibilityElement = true
        imageTap.accessibilityLabel = "Guitar icon, tap twice"
        
        lblWhich.isAccessibilityElement = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        cancelSpeechRecognitization()
    }
    
    @IBAction func goToSetting(_ sender: Any) {
        let settingVC = SettingViewController(settingVM: SettingViewModel())
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func checkDefault() {
        let value = defaults.integer(forKey: "inputMode")
        if (value == 0) {
            tabBarController?.viewControllers?.remove(at: 1)
        } else {
            tabBarController?.viewControllers?.remove(at: 0)
        }
    }
    
    private func lottieAnimation(){
        UIView.animate(withDuration: 0.5) {
            self.animationView.alpha = 1
        }
        
        animationView.animation = Animation.named("circle-grow-2")
        animationView.frame = imageTap.frame
        animationView.contentMode = .scaleAspectFit
        animationView.isHidden = false
        animationView.loopMode = .loop
        animationView.play()
        view.insertSubview(animationView, belowSubview: imageTap)
    }
    
    private func hideAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.animationView.alpha = 0
        }
    }
    
    private func playSound() {
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
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        isStart = !isStart
        
        if (isStart) {
            //Start with delay if voice over running
            if UIAccessibility.isVoiceOverRunning {
                self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
                    // Do whatever needs to be done when the timer expires
                    self.playSound()
                    self.lottieAnimation()
                    self.speechRecognitionActive()
                })
                //Start immediately if no voice over detected
            } else {
                self.playSound()
                self.lottieAnimation()
                self.speechRecognitionActive()
            }
            
        } else {
            cancelSpeechRecognitization()
            hideAnimation()
        }
    }
    
    private func speechRecognitionActive() {
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
            alertView(message: "Error Start Audio Listener")
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            self.alertView(message: "Recognization is now allow on your local")
            
            return
        }
        
        if !myRecognization.isAvailable {
            self.alertView(message: "Recognization is not available")
        }
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if let result = result {
                self.lblResult.text = result.bestTranscription.formattedString
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
                    self.cancelSpeechRecognitization()
                    self.hideAnimation()
                })
            }
        })
        
        if ( task.isFinishing == true) {
            let text = lblResult.text
            let _ = text?.split {
                $0.isWhitespace
            }.map {
                String($0)
            }
        }
    }
    
    var chordToResponse = ""
    
    var chordNameModel = ChordName()
    
    private func cancelSpeechRecognitization() {
        
        if ( task != nil) {
            task.finish()
            task.cancel()
            task = nil
            
            let speechUtterance = AVSpeechUtterance(string: self.lblResult.text!)
            
            speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
            speechSynthesizer.speak(speechUtterance)
            
            //Call the API
            let chord = self.lblResult.text
            
            guard let chordSave = chord else {return}
            
            chordNameModel = Helper().convertStringToParam(chord: chordSave)
            
            guard let chordURLParameterSave = chordNameModel.urlParameter else {
                return
            }
            
            //For Checking But Duplicate
            DispatchQueue.global().async {
                
                self.task = nil
                
                NetworkManager().getSpecificChord(chord: chordURLParameterSave) { chordResult in
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toChordDetail", sender: self)
                    }
                    
                } completionFailed: { isFailed in
                    
                    let textFailed = "Chord not found, please input again"
                    
                    if ( isFailed == true) {
                        
                        let speechUtterance = AVSpeechUtterance(string: textFailed)
                        
                        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
                        self.speechSynthesizer.speak(speechUtterance)
                        
                        // Re-call
                        DispatchQueue.main.async {
                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                                // Do whatever needs to be done when the timer expires
                                self.playSound()
                                self.lottieAnimation()
                                self.speechRecognitionActive()
                                
                            })
                        }
                    }
                }
            }
        }
        
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let chordURLParameterSave = chordNameModel.urlParameter else {
            return
        }
        
        if segue.identifier == "toChordDetail" {
            let destination = segue.destination as? ChordDetailViewController
            destination?.selectedChord = self.chordNameModel
            destination?.senderPage = 0
            print(self.chordNameModel)
            
            DispatchQueue.global().async {
                NetworkManager().getSpecificChord(chord:chordURLParameterSave) { model in
                    
                    destination?.chordModel = model
                    
                } completionFailed: { failed in
                    print(failed)
                }
            }
        }
    }
    
    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("Accepted")
                } else if authState == .denied {
                    self.alertView(message: "Denied")
                } else if ( authState == .notDetermined) {
                    self.alertView(message: "In User phone There's no Speech Recog")
                } else if authState == .restricted {
                    self.alertView(message: "Restricted")
                }
            }
        }
    }
    
    private func alertView(message: String) {
        let controller = UIAlertController.init(title: "Error ocured...!", message: message, preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            controller.dismiss(animated: true, completion: nil)
        }))
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func unwindToVoice(_ sender: UIStoryboardSegue) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
