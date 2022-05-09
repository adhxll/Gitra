//
//  ChordPickerViewController.swift
//  Gitra
//
//  Created by Christopher Teddy  on 07/06/21.
//

import UIKit
import AVFoundation

class ChordPickerViewController: UIViewController {
    
    var viewModel = ChordPickerViewModel()
    
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chordPicker: UIPickerView!
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("Error")
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.extendedLayoutIncludesOpaqueBars = true

        chordPicker.dataSource = self
        chordPicker.delegate = self
        
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Setting"
        updateUIValue()
    }
    
    func updateUIValue() {
        viewModel.root = viewModel.note[chordPicker.selectedRow(inComponent: 0)]
        viewModel.quality = viewModel.chord[chordPicker.selectedRow(inComponent: 1)].quality ?? ""
        viewModel.tension = viewModel.chord[chordPicker.selectedRow(inComponent: 1)].tension?[chordPicker.selectedRow(inComponent: 2)] ?? ""
        
        viewModel.result.accessibilityLabel = viewModel.selectedChordLabel()
        chooseButton.accessibilityLabel = "Choose Chord, " + viewModel.result.accessibilityLabel!
    }
    
    @IBAction func chooseChord(_ sender: Any) {
        viewModel.chooseChordValue()
        performSegue(withIdentifier: "todetail", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let result = viewModel.result
        if segue.identifier == "todetail" {
            let destination = segue.destination as? ChordDetailViewController
            destination?.selectedChord = result
            destination?.senderPage = 1
            
            DispatchQueue.global().async {
                NetworkManager().getSpecificChord(chord: result.urlParameter!) { model in
                    
                    destination?.chordModel = model
                    
                } completionFailed: { failed in
                    print(failed)
                }
            }
            self.hidesBottomBarWhenPushed = true
        }
    }
    
    @IBAction func goToSetting(_ sender: Any) {
        let settingVC = SettingViewController(settingVM: SettingViewModel())
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
}

extension ChordPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let note = viewModel.note
        let chord = viewModel.chord
        if component == 0 {
            return note.count
        } else if component == 1 {
            return chord.count
        }
        let selectedRow = chordPicker.selectedRow(inComponent: 1)
        return chord[selectedRow].tension?.count ?? 1
    }
}

extension ChordPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let note = viewModel.note
        let chord = viewModel.chord
        var pickerLabel: UILabel? = (view as? UILabel)
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.font = UIFont(name: "Product Sans Bold", size: 42)
        
        if component == 0 {
            pickerLabel?.text = note[row]
            pickerLabel?.accessibilityLabel = "Chord Root, " + viewModel.transformChordAccessibility(note[row]) + "."
            pickerLabel?.accessibilityTraits = .adjustable
        }
        else if component == 1 {
            pickerLabel?.text = chord[row].quality
            pickerLabel?.accessibilityLabel = "Chord Type, " + viewModel.transformChordAccessibility(chord[row].quality ?? "") + "."
            pickerLabel?.accessibilityTraits = .adjustable
        } else {
            let selectedRow = chordPicker.selectedRow(inComponent: 1)
            pickerLabel?.text = chord[selectedRow].tension?[row]
            pickerLabel?.accessibilityLabel = "Chord Tension, " + viewModel.transformChordAccessibility(chord[selectedRow].tension?[row] ?? "") + "."
            pickerLabel?.accessibilityTraits = .adjustable
        }
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
        DispatchQueue.main.async {
            self.updateUIValue()
        }
    }
    
    @IBAction func unwindToPicker(_ sender: UIStoryboardSegue) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
