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
import Combine

class ChordVoiceViewController: UIViewController {
    
    var viewModel = ChordVoiceViewModel()
    
    @IBOutlet weak var textLogo: UIImageView!
    @IBOutlet weak var imageTap: UIImageView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblWhich: UILabel!
    
    
    //MARK: - Local Properties
    var isStart: Bool = false
    let animationView = AnimationView()
    let defaults = UserDefaults.standard
    var chordToResponse = ""
    
    //Subscriber
    var chordResultSubscriber: AnyCancellable?
    var chordFoundSubscriber: AnyCancellable?
    var alertMessageSubscriber: AnyCancellable?
    var speechRegSubscriber: AnyCancellable?
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("Error")
        }
        changeLblResult(to: "Tap the icon to start..")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeInherentProperties()
        initializeImageTap()
        requestPermission()
        initializeTextLogo()
        initializeLblWhich()
        initializeSubscribers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.killAudioEngine()
        hideAnimation()
    }
    
    func initializeSubscribers(){
        chordResultSubscriber = viewModel.$chordResult.sink(receiveValue: { result in
            self.changeLblResult(to: result)
        })
        chordFoundSubscriber = viewModel.$chordFound.sink(receiveValue: { result in
            if result {
                self.viewModel.utter(text: self.lblResult.text ?? self.viewModel.chordResult)
                self.pushToChordDetail()
            }
        })
        alertMessageSubscriber = viewModel.$alertMessage.sink(receiveValue: { message in
            if message != "" {
                self.alertView(message: message)
            }
        })
        speechRegSubscriber = viewModel.$isRecognizingSpeech.sink(receiveValue: { result in
            if result{
                self.startAnimation()
                self.changeLblResult(to: "Say something...")
            }else{
                self.hideAnimation()
            }
        })
    }
    
    func initializeInherentProperties() {
        UINavigationBar.appearance().isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        self.extendedLayoutIncludesOpaqueBars = true
        self.tabBarController?.tabBar.isHidden = false
        //        checkDefault()
    }
    
    func initializeImageTap(){
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageTapped(tapGestureRecognizer:)))
        imageTap.isUserInteractionEnabled = true
        imageTap.addGestureRecognizer(tapGestureRecognizer)
        imageTap.isAccessibilityElement = true
        imageTap.accessibilityLabel = "Guitar icon, tap to begin"
    }
    
    func initializeTextLogo() {
        textLogo.isAccessibilityElement = true
        textLogo.accessibilityHint = "Which chord do you want to play? Please tap the The Guitar Icon once then say the chord you would like to search and wait 5 seconds for the result."
    }
    
    func initializeLblWhich(){
        lblWhich.isAccessibilityElement = false
    }
    
    func changeLblResult(to string:String) {
        lblResult.text = string
    }
    
    //    func checkDefault() {
    //        let value = defaults.integer(forKey: "inputMode")
    //        if (value == 0) {
    //            tabBarController?.viewControllers?.remove(at: 1)
    //        } else {
    //            tabBarController?.viewControllers?.remove(at: 0)
    //        }
    //    }
    
    func startVoiceRecognition() {
        viewModel.activateSpeechRecognition(utter: lblResult.text ?? "")
    }
    
    func stopVoiceRecognition() {
        viewModel.deactivateSpeechRecognitization()
    }
    
    // lottie animation
    private func startAnimation(){
        viewModel.playSpeechRecognitionSoundIndicator()
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
    
    @objc func onImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        isStart = !isStart
        if (isStart) {
            //Start with delay if voice over running
            if UIAccessibility.isVoiceOverRunning {
                viewModel.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
                    // Do whatever needs to be done when the timer expires
                    self.startVoiceRecognition()
                })
                //Start immediately if no voice over detected
            } else {
                self.startVoiceRecognition()
            }
            
        } else {
            stopVoiceRecognition()
        }
    }
    
}

/// MARK: Permission, alerts
extension ChordVoiceViewController {
    
    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("Accepted")
                } else if authState == .denied {
                    self.alertView(message: "Denied")
                } else if ( authState == .notDetermined) {
                    self.alertView(message: "No Speech Recognition in user's phone")
                } else if authState == .restricted {
                    self.alertView(message: "Restricted")
                }
            }
        }
    }
    
    private func alertView(message: String) {
        let alert = UIAlertController.init(title: "Error occured...!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

/// MARK: Navigation
extension ChordVoiceViewController {
    
    func pushToChordDetail() {
        self.performSegue(withIdentifier: "toChordDetail", sender: self)
    }
    
    @IBAction func goToSetting(_ sender: Any) {
        let settingVC = SettingViewController(settingVM: SettingViewModel())
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let chordURLParameterSave = viewModel.chordNameModel.urlParameter else {
            return
        }
        
        if segue.identifier == "toChordDetail" {
            let destination = segue.destination as? ChordDetailViewController
            destination?.selectedChord = viewModel.chordNameModel
            destination?.senderPage = 0
            print(viewModel.chordNameModel)
            
            DispatchQueue.global().async {
                NetworkManager().getSpecificChord(chord:chordURLParameterSave) { model in
                    
                    destination?.chordModel = model
                    
                } completionFailed: { failed in
                    print(failed)
                }
            }
        }
    }
    
    @IBAction func unwindToVoice(_ sender: UIStoryboardSegue) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
