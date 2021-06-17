//
//  ChordPickerViewController.swift
//  Gitra
//
//  Created by Christopher Teddy  on 07/06/21.
//

import UIKit

class ChordPickerViewController: UIViewController {
    
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chordPicker: UIPickerView!
    
    var note = Database.shared.getNote()
    var chord = Database.shared.getChord()
    
    var root = ""
    var quality = ""
    var tension = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()

        chordPicker.dataSource = self
        chordPicker.delegate = self
        
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Setting"
        updateUI()
    }
    
    var result = ""
    
    @IBAction func chooseChord(_ sender: Any) {
        var input = root + "_" + quality + tension
        input = transformChordAPI(input)
        result = input
        
        performSegue(withIdentifier: "todetail", sender: self)
        print(input)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "todetail" {
            DispatchQueue.global().async {
                NetworkManager().getSpecificChord(chord:self.result) { model in
                    
                    let destination = segue.destination as? ChordDetailViewController
                    
                    print("OY", model)
                    
                    destination?.chordModel = model
                } completionFailed: { failed in
                    print(failed)
                }
            }
         
        }
    }
 
    @IBAction func goToSetting(_ sender: Any) {
        let pvc = UIStoryboard(name: "Setting", bundle: nil)
        let settingVC = pvc.instantiateViewController(withIdentifier: "setting")
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func updateUI() {
        root = note[chordPicker.selectedRow(inComponent: 0)]
        quality = chord[chordPicker.selectedRow(inComponent: 1)].quality ?? ""
        tension = chord[chordPicker.selectedRow(inComponent: 1)].tension?[chordPicker.selectedRow(inComponent: 2)] ?? ""
        
        chooseButton.accessibilityLabel = selectedChordLabel()
    }
    
    func selectedChordLabel() -> String {
        let selectedChord = (transformChordAccessibility(root) +  transformChordAccessibility(quality) + transformChordAccessibility(tension))
        
        return "Choose Chord, \(selectedChord)"
    }
    
    func transformChordAPI(_ input: String) -> String {
        var output = input
        output = output.lowercased()
        
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
        
        output.capitalizeFirstLetter()
        
        return output
    }
    
    func transformChordAccessibility(_ input: String) -> String {
        var output = input
        output = output.replacingOccurrences(of: "♯", with: "Sharp")
        output = output.replacingOccurrences(of: "♭", with: "Flat")
        
        switch output {
        case "Dim":
            output = "Diminished"
        case "Sus":
            output = "Suspended"
        case "Aug":
            output = "Augmented"
        default:
            break
        }
        return output
    }
}

extension ChordPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
        var pickerLabel: UILabel? = (view as? UILabel)
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.font = UIFont(name: "Product Sans Bold", size: 42)
        
        if component == 0 {
            pickerLabel?.text = note[row]
            pickerLabel?.accessibilityLabel = "Root, " + transformChordAccessibility(note[row]) + "."
            pickerLabel?.accessibilityTraits = .adjustable
        }
        else if component == 1 {
            pickerLabel?.text = chord[row].quality
            pickerLabel?.accessibilityLabel = "Type, " + transformChordAccessibility(chord[row].quality ?? "") + "."
            pickerLabel?.accessibilityTraits = .adjustable
        } else {
            let selectedRow = chordPicker.selectedRow(inComponent: 1)
            pickerLabel?.text = chord[selectedRow].tension?[row]
            pickerLabel?.accessibilityLabel = "Tension, " + transformChordAccessibility(chord[selectedRow].tension?[row] ?? "") + "."
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
            self.updateUI()
        }
    }
}
