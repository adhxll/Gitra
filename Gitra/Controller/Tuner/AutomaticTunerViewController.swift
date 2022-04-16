//
//  AutomaticTunerViewController.swift
//  Gitra
//
//  Created by Yahya Ayyash on 13/06/21.
//

import UIKit
import AudioKit

class AutomaticTunerViewController: UIViewController, TunerDelegate {
    
    @IBOutlet var strings: [UIButton]!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var conductor = TunerConductor()
    var indicatorCircle: CAShapeLayer?
    var backgroundCircle: CAShapeLayer?
    var start = false
    var selectedString = ""
    var timer1: Timer?
    var timer2: Timer?
    var tempKey = ""
    var newKey = ""
    
    override func viewWillAppear(_ animated: Bool) {
        
        UINavigationBar.appearance().isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.isHidden = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        do {
            try Settings.setSession(category: .playAndRecord, with: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("AudioKit error")
        }
    }
    
    // Detect status changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" {
            if (change?[.oldKey] as! String) != (change?[.newKey] as! String) {
                UIAccessibility.post(notification: .announcement, argument: statusLabel.text)
            }
            tempKey = (change?[.oldKey] as! String)
            newKey = (change?[.newKey] as! String)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        conductor.delegate = self
        
        statusLabel.addObserver(self, forKeyPath: "text", options: [.old, .new], context: nil)
        
        //Set button tag and style
        for (index, button) in strings.enumerated() {
            button.tag = index
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
        }
        
        differenceLabel.isHidden = true
        differenceLabel.layer.cornerRadius = differenceLabel.frame.height / 2
        differenceLabel.layer.masksToBounds = true
        
        //Define background circle
        backgroundCircle = CAShapeLayer()
        backgroundCircle?.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: viewIndicator.frame.width, height: viewIndicator.frame.height)).cgPath
        backgroundCircle?.fillColor = UIColor.systemGray6.cgColor
        
        //Define indicator circle
        indicatorCircle = CAShapeLayer()
        indicatorCircle?.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: viewIndicator.frame.width, height: viewIndicator.frame.height)).cgPath
        indicatorCircle?.fillColor = UIColor.ColorLibrary.yellowAccent.cgColor
        
        //Add background & indicator as view sublayer
        viewIndicator.layer.insertSublayer(backgroundCircle!, at: 0)
        viewIndicator.layer.insertSublayer(indicatorCircle!, at: 1)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopAll()
    }
    
    @IBAction func goToSetting(_ sender: Any) {
        let settingVC = SettingViewController(settingVM: SettingViewModel())
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @IBAction func startTuner(_ sender: Any) {
        if !start {
            self.conductor.start()
            
            UIAccessibility.post(notification: .announcement, argument: "Start plucking your guitar string.")
            
            start = true
            startButton.setTitle("Stop", for: .normal)
            differenceLabel.isHidden = false
            
            startTimer()
            
        } else {
            stopAll()
        }
    }
    
    func stopAll() {
        self.conductor.stop()
        
        //Reset all elements to inital state
        timer1?.invalidate()
        timer2?.invalidate()
        setDefaultButton()
        selectedString = ""
        statusLabel.text = "Tap the start button to start tuning"
        indicatorCircle?.position = CGPoint(x: 0, y: 0)
        startButton.setTitle("Start", for: .normal)
        start = false
        differenceLabel.isHidden = true
    }
    
    @IBAction func buttonSelected(_ sender: UIButton) {
        
        setDefaultButton()
        
        let setFrequency = NoteFrequency.allCases[sender.tag]
        conductor.noteFrequency = setFrequency.rawValue
        sender.backgroundColor = .ColorLibrary.yellowAccent
    }
    
    func tunerDidMeasure(pitch: Float, amplitude: Float, target: Float) {
        
        let freqGap: Float = pitch - target
        let errorDiff: Float = target * 0.5
        let frame = self.view.frame.width / 2
        var position = CGPoint()
        
        // Update highlight button to match the string target
        updateButton(target: target)
        
        if abs(freqGap) < errorDiff { // Target note is pretty close
            let mappedPos = map(minRange: Int(target - errorDiff), maxRange: Int(target + errorDiff), minDomain: Int(-frame), maxDomain: Int(frame), value: Int(pitch))
            position = CGPoint(x: mappedPos, y: 0)
            
            if abs(freqGap) < target * 0.005 {
                
                statusLabel.text = "Hold"
                indicatorCircle?.fillColor = UIColor.systemGreen.cgColor
                
            } else {
                
                if selectedString != "" {
                    statusLabel.text = freqGap > 0 ? (selectedString + " is too sharp, tune it down") : (selectedString + " is to flat, tune it up")
                } else {
                    statusLabel.text = ""
                }
                
                indicatorCircle?.fillColor = UIColor.ColorLibrary.yellowAccent.cgColor
            }
        } else { // Target note is much lower or larger

            indicatorCircle?.fillColor = UIColor.ColorLibrary.orangeAccent.cgColor
            position = freqGap > 0 ? CGPoint(x: frame, y: 0) : CGPoint(x: -frame, y: 0)
            if selectedString != "" {
                statusLabel.text = freqGap > 0 ? (selectedString + " is too sharp, tune it down") : (selectedString + " is to flat, tune it up")
            } else {
                statusLabel.text = ""
            }
        }
        
        let diff = (round(100 * freqGap)) / 100
        differenceLabel.text = "\(diff)"
        indicatorCircle?.position = position
        
    }
    
    func map(minRange: Int, maxRange: Int, minDomain: Int, maxDomain: Int, value: Int) -> Int {
        return minDomain + (maxDomain - minDomain) * (value - minRange) / (maxRange - minRange)
    }
    
    func updateButton(target: Float) {
        if target == NoteFrequency.string1.rawValue {
            buttonSelected(strings[0])
            selectedString = "E string"
        }
        if target == NoteFrequency.string2.rawValue {
            buttonSelected(strings[1])
            selectedString = "B string"
        }
        if target == NoteFrequency.string3.rawValue {
            buttonSelected(strings[2])
            selectedString = "G string"
        }
        if target == NoteFrequency.string4.rawValue {
            buttonSelected(strings[3])
            selectedString = "D string"
        }
        if target == NoteFrequency.string5.rawValue {
            buttonSelected(strings[4])
            selectedString = "A string"
        }
        if target == NoteFrequency.string6.rawValue {
            buttonSelected(strings[5])
            selectedString = "E string"
        }
    }
    
    func setDefaultButton() {
        // Set button color on the stack view
        strings.forEach({ $0.backgroundColor = .ColorLibrary.whiteAccent })
    }
    
    func startTimer() {
        timer1 = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            if (self.tempKey == self.newKey) {
                UIAccessibility.post(notification: .announcement, argument: self.statusLabel.text)
            }
        }
        timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if (self.tempKey == self.newKey) && self.tempKey == "Hold" {
                self.statusLabel.text = self.selectedString + " is tuned in!"
                self.checkTuneStatus()
            }
        }
    }
    
    @objc func checkTuneStatus() {
        if statusLabel.text == selectedString + " is tuned in!" {
            timer1?.invalidate()
            timer2?.invalidate()
            startTimer()
        }
        UIAccessibility.post(notification: .announcement, argument: statusLabel.text)
    }
}
