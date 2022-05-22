//
//  AutomaticTunerViewController.swift
//  Gitra
//
//  Created by Yahya Ayyash on 13/06/21.
//

import UIKit
import AudioKit

enum AutomaticTunerStatus {
    case initial
    case idle
    case analyzing
    case tunedIn
    case tooFlat
    case tooSharp
    
    var localizedString: String {
        switch self {
        case .initial:
            return NSLocalizedString("automaticTuner.status-label-initial.title", comment: "")
        case .analyzing:
            return NSLocalizedString("automaticTuner.status-label-hold.title", comment: "")
        case .tunedIn:
            return NSLocalizedString("automaticTuner.status-label-match.title", comment: "")
        case .tooFlat:
            return NSLocalizedString("automaticTuner.status-label-too-flat.title", comment: "")
        case .tooSharp:
            return NSLocalizedString("automaticTuner.status-label-too-sharp.title", comment: "")
        case .idle:
            return ""
        }
    }
}

class AutomaticTunerViewController: UIViewController, TunerDelegate {
    
    @IBOutlet var stringButtons: [UIButton]!
    @IBOutlet weak var tunerIndicatorView: UIView!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    private let conductor: TunerConductor = TunerConductor()
    private let viewModel: AutomaticTunerViewModel = AutomaticTunerViewModel()
    
    private let indicatorCircleShapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.ColorLibrary.yellowAccent.cgColor
        return shape
    }()
    
    private let backgroundCircleShapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.systemGray6.cgColor
        return shape
    }()
    
    private var tunerStatus: AutomaticTunerStatus = .initial {
        didSet {
            if tunerStatus == .initial || tunerStatus == .idle || tunerStatus == .analyzing {
                statusLabel.text = tunerStatus.localizedString
            } else {
                statusLabel.text = selectedString + " " + tunerStatus.localizedString
                if shouldActiveVoiceOver {
                    UIAccessibility.post(notification: .announcement, argument: statusLabel.text)
                    shouldActiveVoiceOver = false
                }
            }
        }
        willSet {
            // Only change the status to tunedIn if after 4s the tunerStatus value isn't changed, otherwise invalidate the timer
            if newValue == tunerStatus && tunerStatus == .analyzing {
                if timer2 == nil {
                    timer2 = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
                        guard let weakSelf = self else { return }
                        if (weakSelf.tunerStatus == .analyzing) {
                            weakSelf.tunerStatus = .tunedIn
                        }
                    }
                }
            } else if newValue != tunerStatus {
                shouldActiveVoiceOver = true
            } else {
                timer2?.invalidate()
                timer2 = nil
            }
        }
    }
    
    private var selectedString: String = "" {
        willSet {
            // Everytime the selectedString value changed, invalidate the timer
            if newValue != selectedString {
                shouldActiveVoiceOver = true
                timer2?.invalidate()
                timer2 = nil
            }
        }
    }
    
    private var shouldActiveVoiceOver: Bool = false
    private var isStarted: Bool = false
    private var timer1: Timer?
    private var timer2: Timer?
    
    // MARK: - Private Methods
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action = self
        conductor.delegate = self
        
        setupView()
        setupAudioSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetAllState()
    }
    
    // MARK: - IBAction
    
    @IBAction func goToSetting(_ sender: Any) {
        let settingVC: SettingViewController = SettingViewController(settingVM: SettingViewModel())
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @IBAction func startTuner(_ sender: Any) {
        if !isStarted {
            self.conductor.start()
            
            UIAccessibility.post(notification: .announcement, argument: NSLocalizedString("automaticTuner.conductor-start", comment: ""))
            
            isStarted = true
            tunerStatus = .idle
            startButton.setTitle(NSLocalizedString("automaticTuner.button-stop.title", comment: ""), for: .normal)
            differenceLabel.isHidden = false
            /* startTimer() */
        } else {
            resetAllState()
        }
    }
    
    @IBAction func buttonSelected(_ sender: UIButton) {
        setDefaultButton()
        let setFrequency: NoteFrequency = NoteFrequency.allCases[sender.tag]
        conductor.noteFrequency = setFrequency.rawValue
        sender.backgroundColor = .ColorLibrary.yellowAccent
    }
    
    // MARK: - Internal Methods
    
    func setupNavigationBar() {
        UINavigationBar.appearance().isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.isHidden = false
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    func setupAudioSession() {
        do {
            try Settings.setSession(category: .playAndRecord, with: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("AudioKit session error")
        }
    }
    
    func setupView() {
        //Set button tag and style
        for (index, button) in stringButtons.enumerated() {
            button.tag = index
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
        }
        
        differenceLabel.isHidden = true
        differenceLabel.layer.cornerRadius = differenceLabel.frame.height / 2
        differenceLabel.layer.masksToBounds = true
        
        //Define background circle
        backgroundCircleShapeLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: tunerIndicatorView.frame.width, height: tunerIndicatorView.frame.height)).cgPath
        
        //Define indicator circle
        indicatorCircleShapeLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: tunerIndicatorView.frame.width, height: tunerIndicatorView.frame.height)).cgPath
        
        //Add background & indicator as view sublayer
        tunerIndicatorView.layer.insertSublayer(backgroundCircleShapeLayer, at: 0)
        tunerIndicatorView.layer.insertSublayer(indicatorCircleShapeLayer, at: 1)
    }
    
    func resetAllState() {
        self.conductor.stop()
        
        //Reset all elements to its inital state
        timer1?.invalidate()
        timer2?.invalidate()
        setDefaultButton()
        selectedString = ""
        tunerStatus = .initial
        indicatorCircleShapeLayer.fillColor = UIColor.ColorLibrary.yellowAccent.cgColor
        indicatorCircleShapeLayer.position = CGPoint(x: 0, y: 0)
        startButton.setTitle(NSLocalizedString("automaticTuner.button-start.title", comment: ""), for: .normal)
        isStarted = false
        differenceLabel.isHidden = true
    }
    
    func tunerDidMeasure(pitch: Float, amplitude: Float, target: Float) {
        
        // Update highlight button to match the string target
        updateButton(target: target)
        
        // TODO: - Consider to store the frame properties into constant
        viewModel.tunerDidMeasure(pitch: pitch, amplitude: amplitude, target: target, frame: Float(view.bounds.width / 2))
        
    }
    
    func updateButton(target: Float) {
        for (index, item) in NoteFrequency.allCases.enumerated() where target == NoteFrequency.allCases[index].rawValue {
            buttonSelected(stringButtons[index])
            selectedString = item.stringValue
        }
    }
    
    func setDefaultButton() {
        // Set button color on the stack view
        stringButtons.forEach({ $0.backgroundColor = .ColorLibrary.whiteAccent })
    }
    
    /*
     func startTimer() {
         timer1 = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
             guard let weakSelf = self else { return }
             UIAccessibility.post(notification: .announcement, argument: weakSelf.statusLabel.text)
         }
     }
     */
}

extension AutomaticTunerViewController: AutomaticTunerViewModelAction {
    func tunerResultMatch() {
        tunerStatus = .analyzing
        indicatorCircleShapeLayer.fillColor = UIColor.systemGreen.cgColor
    }
    
    func tunerResultClose() {
        indicatorCircleShapeLayer.fillColor = UIColor.ColorLibrary.yellowAccent.cgColor
    }
    
    func tunerResultFar() {
        indicatorCircleShapeLayer.fillColor = UIColor.ColorLibrary.orangeAccent.cgColor
    }
    
    func shouldUpdateLabel(with freqGap: Float) {
        if selectedString.isNotEmpty {
            tunerStatus = freqGap > 0 ? .tooSharp : .tooFlat
        } else {
            tunerStatus = .idle
        }
    }
    
    func updateIndicatorPosition(position: Float, difference: Float) {
        differenceLabel.text = "\(difference)"
        indicatorCircleShapeLayer.position = CGPoint(x: CGFloat(position), y: .zero)
    }
}
