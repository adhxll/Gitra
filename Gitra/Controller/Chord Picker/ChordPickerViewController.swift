//
//  ChordPickerViewController.swift
//  Gitra
//
//  Created by Christopher Teddy  on 07/06/21.
//

import UIKit
import AVFoundation

class ChordPickerViewController: UIViewController {
    
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chordPicker: UIPickerView!
    
    private var viewModel: ChordPickerViewModel = ChordPickerViewModel()
    private var result: ChordName = ChordName(title: "", accessibilityLabel: "", urlParameter: "")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chordPicker.dataSource = self
        chordPicker.delegate = self
        updateUI()
        setupAudioSession()
    }
    
    // Need to handle tabBar.isHidden property
    // Thus, this should be called on viewWillAppear not viewDidLoad
    private func setupUI() {
        setupAccessibility()
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItem?.accessibilityLabel = NSLocalizedString("chordPicker.navigation-settings.accessibilityLabel", comment: "")
    }
    
    private func setupAccessibility() {
        
    }
    
    // Updating accessibility label for 'Choose Chord' button
    private func updateUI() {
        let root = selectedRow(at: 0)
        let quality = selectedRow(at: 1)
        let tension = selectedRow(at: 2)
        let item = viewModel.generateSelectedChord(root: root, quality: quality, tension: tension)
        chooseButton.accessibilityLabel = NSLocalizedString("chordPicker.button-choose.accessibilityLabel", comment: "") + item.accessibiltyLabel
    }
    
    // If this doesn't work, call this method in viewWillAppear
    private func setupAudioSession() {
        do { try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                             mode: .default,
                                                             options: [.defaultToSpeaker, .allowBluetooth]) }
        catch { print("There was an error setting up the audio session.") }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "todetail" {
            let destination = segue.destination as? ChordDetailViewController
            destination?.selectedChord = self.result
            destination?.senderPage = 1
            
            // TODO: Consider to move this
            DispatchQueue.global().async {
                NetworkManager().getSpecificChord(chord:self.result.urlParameter!) { model in
                    destination?.chordModel = model
                } completionFailed: { failed in
                    print(failed)
                }
            }
            self.hidesBottomBarWhenPushed = true
        }
    }
    
    // Get selected row from UIPickerView components
    func selectedRow(at index: Int) -> Int {
        return chordPicker.selectedRow(inComponent: index)
    }
    
    // MARK: - IBAction
    @IBAction func chooseChord(_ sender: Any) {
        result.urlParameter = viewModel.selectedChord.apiFormat
        result.title = viewModel.selectedChord.apiFormat.replacingOccurrences(of: "_", with: "")
        
        performSegue(withIdentifier: "todetail", sender: self)
    }
    
    @IBAction func goToSetting(_ sender: Any) {
        let settingVC = SettingViewController(settingVM: SettingViewModel())
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @IBAction func unwindToPicker(_ sender: UIStoryboardSegue) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - UIPickerView Data Source
extension ChordPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return viewModel.noteCount() }
        else if component == 1 { return viewModel.qualityCount() }
        return viewModel.tensionCount(for: selectedRow(at: 1))
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: "Product Sans Bold", size: 42)
            label.textAlignment = .center
            label.accessibilityTraits = .adjustable
            return label
        }()
        
        if component == 0 {
            let currItem = viewModel.noteForRow(at: row)
            pickerLabel.text = currItem.title
            pickerLabel.accessibilityLabel = currItem.accessibiltyLabel
        } else if component == 1 {
            let currItem = viewModel.qualityForRow(at: row)
            pickerLabel.text = currItem.title
            pickerLabel.accessibilityLabel = currItem.accessibiltyLabel
        } else {
            let currItem = viewModel.tensionForRow(at: row, for: selectedRow(at: 1))
            pickerLabel.text = currItem.title
            pickerLabel.accessibilityLabel = currItem.accessibiltyLabel
        }
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70
    }
}

// MARK: - UIPickerView Delegate
extension ChordPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }
}
