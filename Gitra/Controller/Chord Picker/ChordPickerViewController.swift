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
    
    var result = ChordName(title: "", accessibilityLabel: "", urlParameter: "")
    
    var root = ""
    var quality = ""
    var tension = ""
    
    var chordPickerVM = ChordPickerViewModel()
    
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
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Setting"
    }
    
    // Updating accessibility label for 'Choose Chord' button
    private func updateUI() {
        chordPickerVM.root = selectedRow(at: 0)
        chordPickerVM.quality = selectedRow(at: 1)
        chordPickerVM.tension = selectedRow(at: 2)
        let root = selectedRow(at: 0)
        let quality = selectedRow(at: 1)
        let tension = selectedRow(at: 2)
        let item = chordPickerVM.generateSelectedChord(root: root, quality: quality, tension: tension)
        chooseButton.accessibilityLabel = "Choose Chord, " + item.accessibiltyLabel
    }
    
    // If this doesn't work, call this method in viewWillAppear
    private func setupAudioSession() {
        do { try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                             mode: .default,
                                                             options: [.defaultToSpeaker, .allowBluetooth]) }
        catch { print("Error") }
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
    
    func transformChordAPI(_ input: String) -> String {
        var output = input.lowercased().capitalizingFirstLetter()
        
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
        
        result.title = output
        output = ChordPickerHelper().swappingSharp(output)
        
        return output
    }
    
    // Get selected row from UIPickerView components
    func selectedRow(at index: Int) -> Int {
        return chordPicker.selectedRow(inComponent: index)
    }
    
    // MARK: - IBAction
    @IBAction func chooseChord(_ sender: Any) {
        var input = root + "_" + quality + tension
        input = transformChordAPI(input)
        result.urlParameter = input
        result.title = result.title?.replacingOccurrences(of: "_", with: "")
        
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
        if component == 0 { return chordPickerVM.noteCount() }
        else if component == 1 { return chordPickerVM.qualityCount() }
        return chordPickerVM.tensionCount(for: selectedRow(at: 1))
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
            let currItem = chordPickerVM.noteForRow(at: row)
            pickerLabel.text = currItem.title
            pickerLabel.accessibilityLabel = currItem.accessibiltyLabel
        } else if component == 1 {
            let currItem = chordPickerVM.qualityForRow(at: row)
            pickerLabel.text = currItem.title
            pickerLabel.accessibilityLabel = currItem.accessibiltyLabel
        } else {
            let currItem = chordPickerVM.tensionForRow(at: row, for: selectedRow(at: 1))
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
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}
