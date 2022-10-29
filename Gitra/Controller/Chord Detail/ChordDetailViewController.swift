//
//  ChordDetailViewController.swift
//  Gitra
//
//  Created by Christopher Teddy  on 07/06/21.
//

import UIKit
import Speech
import AVFoundation
import Lottie
import Foundation

class ChordDetailViewController: UIViewController {
    
    @IBOutlet var fretImage:UIImageView!
    @IBOutlet var startFret:UILabel!
    @IBOutlet var instructionLabel : UILabel!
    @IBOutlet var openCloseIndicators:UIView!
    @IBOutlet weak var commandLabel: UILabel!
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    @IBOutlet weak var previousz: UIButton!
    @IBOutlet weak var nextz: UIButton!
    @IBOutlet weak var repeatz: UIButton!
    
    //Chord Model for param
    var chordModel:ChordModel?
    var selectedChord: ChordName?
    var senderPage: Int?
    
    var chordDelay: Double = 0.2
    var openIndicator:UIImage = #imageLiteral(resourceName: "O")
    var closeIndicator:UIImage = #imageLiteral(resourceName: "X")
    
    let animationView = AnimationView()
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    
    var workItemSpeech: DispatchWorkItem?
    var workItemCommand: DispatchWorkItem?
    var workItemRecognizer: DispatchWorkItem?
    
    @IBOutlet weak var lblCommand: UILabel!
    
    //Audio
    var player: AVAudioPlayer?
    
    //Timer
    var timer: Timer?
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let speaker = Speaker()
    
    var countFinger = 0
    var strings = [0,0,0,0,0,0] //0 is open and -1 is dead
    var fingering = [0,0,0,0,0,0] //-1 means no fingers are there
    var labelForAccessibility = ["","","","","",""]
    var startingFret = 100 //initialize max value to compare
    var indicators:[FingerIndicator] = []
    
    var countFail:Int = 0
    var goToSetting: Bool = false
    
    //MARK: - View Updates
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationSetup()
        if goToSetting {
            speakInstruction()
        }
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Product Sans Bold", size: 18)
        titleLabel.text = selectedChord?.title
        titleLabel.accessibilityLabel = selectedChord?.accessibilityLabel
        self.navigationItem.titleView = titleLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lottieAnimation(yPos: self.view.frame.maxY * 0.4, show: true)
        setAlpha(isHide: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [self] in
            
            guard chordModel != nil else {
                return
            }
            
            self.translateToCoordinate(chord: chordModel!)
            self.displayIndicators()
            self.generateStringForLabel()
            
            UIView.animate(withDuration: 0.5) {
                self.setAlpha(isHide: false)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                playChord(strings)
            }
            
            changeString(isNext: 1)
            
            let delay: DispatchTime = .now() + (6 * chordDelay) + 0.5
            
            DispatchQueue.main.asyncAfter(deadline: delay){
                speakInstruction()
            }
            
            animationView.stop()
            animationView.alpha = 0
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        destroySpeakRecognition()
        hideAnimation()
        
        workItemSpeech?.cancel()
        workItemCommand?.cancel()
        workItemRecognizer?.cancel()
        speaker.stop()
    }
    
    //MARK: - Displaying Chord, Fingering, & Frets Position
    
    //number of frets juga
    //open or dead
    var currString = -1
    func changeString(isNext: Int){
        var prev = 0
        if currString - 1 >= 0 {
            prev = indicators.count - currString - 1
        } else {
            prev = 5
        }
        indicators[prev].backgroundColor = UIColor.ColorLibrary.whiteAccent
        indicators[prev].setTitleColor(UIColor.ColorLibrary.blackAccent, for: .normal)
        
        if isNext == 1 {
            currString = (currString + 1) % 6
            
            if (currString == 5) {
            }
            
        } else if isNext == 2 {
            currString = (currString - 1)
            if currString < 0{
                currString = 5
            }
        } else if isNext == 3 {
            
        }
        
        instructionLabel.text = labelForAccessibility[currString]
        let imageName = "FretsGlow-" + String(currString + 1)
        fretImage.image = UIImage(named: imageName)
        indicators[indicators.count - 1 - currString].backgroundColor = UIColor.ColorLibrary.orangeAccent
        indicators[indicators.count - 1 - currString].setTitleColor(UIColor.ColorLibrary.whiteAccent, for: .normal)
        previousz.isEnabled = currString == 0 ? false : true
        
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
    
    func displayIndicators(){
        let fretWidth = fretImage.frame.width
        let fretHeight = fretImage.frame.height
        
        let size = CGFloat(fretWidth * 2/27)
        //        let leading = CGFloat(1 / 27 * fretWidth)
        let top = 1 / 41 * fretHeight
        let betweenString = CGFloat((25 / 27 * fretWidth) / 5)
        let betweenFret = CGFloat((fretHeight - top) / 5)
        
        for i in 0..<strings.count{
            let indicator: FingerIndicator = {
                let button = FingerIndicator(title: fingering[i])
                return button
            }()
            if fingering[i]>0{ //check if there's an indicator or not
                fretImage.addSubview(indicator)
                indicator.layer.cornerRadius = size/2
                indicator.frame = CGRect(x: CGFloat((CGFloat(i) * betweenString)), y:  CGFloat(4 * top + (CGFloat(strings[i]-startingFret) * betweenFret)), width: size, height: size)
            }
            indicators.append(indicator)
        }
        startFret.text = String(startingFret - 1)
        
        for i in 0..<strings.count{
            if strings[i] > 0{
                continue
            }else{
                let xPosition = CGFloat(i) * betweenString
                let yPosition = CGFloat(0)
                
                let stringIndicator = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: size, height: size))
                
                if strings[i] == 0{
                    stringIndicator.image = openIndicator
                }else{
                    stringIndicator.image = closeIndicator
                }
                
                openCloseIndicators.addSubview(stringIndicator)
                
            }
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
    
    //MARK: - Speech Recognition
    
    private func speechRecognitionActive() {
        
        self.playSound()
        lottieAnimation(yPos: self.commandLabel.frame.maxY, show: true)
        
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
        
        var isFinal = false
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let resultCommand = result.bestTranscription.formattedString
                // Should I compare the result here to see if it changed?
                self.lblCommand.text = resultCommand
                isFinal = result.isFinal
                
            }
            
            if isFinal {
                
            } else if error == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                    // Do whatever needs to be done when the timer expires
                    self.cancelSpeechRecognitization(resultCommand: self.lblCommand.text ?? "")
                    
                })
            }
        })
        
        if (task.isFinishing == true) {
            let lowerCased = self.lblCommand.text!.lowercased()
            
            if (lowerCased == "next") {
                print("Next")
            }
        }
    }
    
    private func cancelSpeechRecognitization(resultCommand: String) {
        
        if ( task != nil) {
            task.finish()
            task.cancel()
            task = nil
            
            self.hideAnimation()
            
            let lowerCased = resultCommand.lowercased()
            
            if (lowerCased == "next") {
                countFail = 0
                
                if currString < 5 {
                    changeString(isNext: 1)
                    speakInstruction()
                } else {
                    finish()
                }
                
                // print("Next bawah")
            } else if ( lowerCased == "previous") {
                countFail = 0
                
                changeString(isNext: 2)
                speakInstruction()
            } else if ( lowerCased == "repeat") {
                countFail = 0
                
                changeString(isNext: 3)
                speakInstruction()
            } else if ( lowerCased == "finish") {
                countFail = 0
                
                request.endAudio()
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
                
                finish()
                
            } else if ( lowerCased == "start over") {
                currString = -1
                changeString(isNext: 1)
                speakInstruction()
                countFail = 0
            } else {
                //If the word is not match from the constraint above
                //Sound Feedback On
                
                if ( countFail < 2) {
                    speaker.speak("Voice feedback is not available, please Input your voice again", playNote: "")
                    countFail = countFail + 1
                    
                    self.timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (timer) in
                        // Do whatever needs to be done when the timer expires
                        self.speechRecognitionActive()
                        self.lblCommand.text = "Listening..."
                        
                    })
                    
                    print(countFail)
                    
                } else {
                    speaker.speak("Please use the button instead", playNote: "")
                    
                    self.lblCommand.text = "Listening..."
                    
                    destroySpeakRecognition()
                }
            }
        }
        destroySpeakRecognition()
    }
    
    private func destroySpeakRecognition() {
        lottieAnimation(yPos: self.commandLabel.frame.maxY, show: false)
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    //MARK: - UI Updates
    
    private func navigationSetup(){
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = settingButton
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Setting"
        
        self.tabBarController?.tabBar.isHidden = true
        lblCommand.text = ""
    }
    
    private func setAlpha(isHide: Bool){
        if (isHide) {
            fretImage.alpha = 0
            startFret.alpha = 0
            instructionLabel.alpha = 0
            openCloseIndicators.alpha = 0
            commandLabel.alpha = 0
//            previousz.alpha = 0
//            nextz.alpha = 0
//            repeatz.alpha = 0
//            navigationItem.titleView?.alpha = 0
        } else {
            fretImage.alpha = 1
            startFret.alpha = 1
            instructionLabel.alpha = 1
            openCloseIndicators.alpha = 1
            commandLabel.alpha = 1
//            previousz.alpha = 1
//            nextz.alpha = 1
//            repeatz.alpha = 1
//            navigationItem.titleView?.alpha = 1
        }
    }
    
    private func lottieAnimation(yPos: CGFloat, show: Bool){
        
        if show {
            animationView.isHidden = false
        } else {
            animationView.isHidden = true
            animationView.alpha = 0
        }
        
        animationView.animation = Animation.named("loading-animation-1")
        animationView.frame = CGRect(x: self.view.frame.midX - 25, y: yPos, width: 50, height: 50)
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .loop
        animationView.play()
        view.insertSubview(animationView, aboveSubview: view)
        
        UIView.animate(withDuration: 0.5) {
            self.animationView.alpha = 1
        }
    }
    
    private func hideAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.animationView.alpha = 0
        }
        //        animationView.isHidden = true
    }
    
    //MARK: - Sound Related
    
    private func playSound() {
        guard let url = Bundle.main.path(forResource: "siri", ofType: "m4a") else {
            print("URL not found")
            return
        }
        
        do {
            
            try AVAudioSession.sharedInstance().setActive(true)
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            
            let backgroundMusic = NSURL(fileURLWithPath: url)
            
            player = try AVAudioPlayer(contentsOf: backgroundMusic as URL, fileTypeHint: AVFileType.m4a.rawValue)
            
            guard let player = player else {return}
            
            player.play()
            
        } catch let error {
            print("Error ", error.localizedDescription)
        }
    }
    
    func playChord(_ stringsArray: [Int]) {
        var note = [String]()
        var animatedImages = [UIImage]()
        var stringCount = 0.0
        
        let timeDelay = UserDefaults.standard.integer(forKey: "chordSpeed")
        
        switch timeDelay {
        case 0:
            chordDelay = 0.5
        case 1:
            chordDelay = 0.2
        case 2:
            chordDelay = 0.05
        default:
            break
        }
        
        for (index, frets) in stringsArray.enumerated() {
            if frets >= 0 {
                note.append(Database.shared.getGuitarNote((5 - index), frets))
                animatedImages.append(UIImage(named: "FretsGlow-" + String(6-index)) ?? UIImage())
                stringCount += 1.0
            }
        }
        
        //Animating the image sequence
        fretImage.stopAnimating()
        fretImage.animationImages = animatedImages
        fretImage.animationDuration = chordDelay * stringCount
        fretImage.animationRepeatCount = 1
        
        NotesMapping.shared.playSounds(note, withDelay: chordDelay)
        
        //Start animating
        fretImage.startAnimating()
        fretImage.image = animatedImages.last
    }
    
    private func currentNote(_ senar: Int) -> String {
        let fret = strings[5-senar]
        if fret >= 0 {
            return Database.shared.getGuitarNote(senar, strings[(5 - senar)])
        }
        return ""
    }
    
    private func speakInstruction() {
        let tempString = currString
        let userDefaults = UserDefaults.standard.integer(forKey: "inputCommand")
        
        speaker.stop()
        speaker.speak(instructionLabel.text!, playNote: currentNote(currString))
        
        let delay: DispatchTime = (currentNote(currString) == "") ? (.now() + 0) : (.now() + 3)
        
        workItemSpeech = DispatchWorkItem{
            //Check if user move to the next string before completing the instruction.
            if self.currString == tempString {
                self.speaker.speak(self.instructionLabel.text!, playNote: self.currentNote(self.currString))
            }
        }
        
        workItemCommand = DispatchWorkItem{
            self.speaker.speak("Say ‘repeat’ to repeat the instructions. Say 'next' to move to the next string. Say 'previous' to move to the previous string. Say 'finish' to end the session.", playNote: "")
        }
        
        workItemRecognizer = DispatchWorkItem{
            //Check if user move to the next string before completing the instruction.
            self.speechRecognitionActive()
            self.lblCommand.text = ""
        }
        
        if userDefaults == 0 {
            DispatchQueue.main.asyncAfter(deadline: delay, execute: workItemSpeech!)
            DispatchQueue.main.asyncAfter(deadline: delay + 4, execute: workItemRecognizer!)
        } else {
            DispatchQueue.main.asyncAfter(deadline: delay, execute: workItemSpeech!)
            DispatchQueue.main.asyncAfter(deadline: delay + 4, execute: workItemCommand!)
            DispatchQueue.main.asyncAfter(deadline: delay + 14, execute: workItemRecognizer!)
        }
    }
    
    private func destroyAllSound() {
        destroySpeakRecognition()
        workItemSpeech?.cancel()
        workItemCommand?.cancel()
        workItemRecognizer?.cancel()
        speaker.stop()
    }
    
    //MARK: - IBAction & Other Function
    
    @IBAction func previouszTapped(_ sender: UIBarButtonItem){
        destroySpeakRecognition()
        destroyAllSound()
        changeString(isNext: 2)
        speakInstruction()
        countFail = 0
    }
    
    @IBAction func nextzTapped(_ sender: UIBarButtonItem){
        destroySpeakRecognition()
        destroyAllSound()
        next()
        countFail = 0
    }
    
    private func next() {
        if currString < 5 {
            
            changeString(isNext: 1)
            speakInstruction()
            
        } else {
            finish()
        }
    }
    
    private func finish() {
        
        destroyAllSound()
        
        playChord(strings)
        
        let delay: DispatchTime = .now() + (6 * chordDelay) + 0.5
        
        DispatchQueue.global().asyncAfter(deadline: delay){
            self.speaker.speak("Congratulation You have Learn \(self.selectedChord?.accessibilityLabel ?? "a new Chord")", playNote: "")
        }
        
        //        let defaults = UserDefaults.standard.integer(forKey: "inputMode")
        
        DispatchQueue.main.asyncAfter(deadline: delay + 4){
            if self.senderPage == 0 {
                self.performSegue(withIdentifier: "unwindVoice", sender: self)
            } else {
                self.performSegue(withIdentifier: "unwindPicker", sender: self)
            }
        }
    }
    
    @IBAction func repeatzTapped(_ sender: UIBarButtonItem){
        destroySpeakRecognition()
        destroyAllSound()
        speakInstruction()
    }
    
    @objc func addTapped(){
        goToSetting = true
        
        let settingVC = SettingViewController(settingVM: SettingViewModel())
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    private func alertView(message: String) {
        let controller = UIAlertController.init(title: "Error ocured...!", message: message, preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            controller.dismiss(animated: true, completion: nil)
        }))
        
        self.present(controller, animated: true, completion: nil)
    }
}

//MARK: - Speaker Class

class Speaker: NSObject {
    let synth = AVSpeechSynthesizer()
    var note = ""
    
    override init() {
        super.init()
        synth.delegate = self
    }
    
    func speak(_ str: String, playNote: String){
        let utterance = AVSpeechUtterance(string: str)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        synth.speak(utterance)
        note = playNote
    }
    
    func stop() {
        synth.stopSpeaking(at: .immediate)
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if note != "" {
            NotesMapping.shared.playSound(note)
        }
    }
}
