//
//  ChordInputSpeedViewController.swift
//  Gitra
//
//  Created by Gilang Adrian on 10/06/21.
//

import UIKit

class SettingListViewController: UIViewController{
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var footerLabel: UILabel!
    
    var settingList = SettingsDatabase.shared.getSettings()
    var senderPage: Int?
    var sender: Int?
    var saveKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        checkSourcePage()
        
    }
    
    func checkSourcePage() {
        switch senderPage {
//        case 0 :
//            saveKey = "inputMode"
//            footerLabel.text = "By choosing voice command, you will be able to input a chord by using your voice. Please restart the app to see the changes."
//            self.title = " Chord Input Mode"
        case 2 :
            saveKey = "chordSpeed"
            footerLabel.text = "Determine the chord playback speed on the instruction mode. The default value is normal."
            self.title = "Chord Speed"
        case 3 :
            saveKey = ""
            footerLabel.text = ""
            self.title = "Instructions"
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? InstructionViewController
        destination?.senderPage = self.sender
    }
}

extension SettingListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //Deselect all row to remove checkmark
        if senderPage != 3 {
            for i in 0...(settingList[senderPage ?? 0].menu!.count - 1) {
                tableView.cellForRow(at: [0,i])?.accessoryType = .none
            }
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            UserDefaults.standard.setValue(indexPath.row, forKey: saveKey)
        }
        if senderPage == 3 {
            sender = indexPath.row
            performSegue(withIdentifier: "instructionSegue", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingList[senderPage ?? -1].menu!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "GitraSettingCell")
        cell.textLabel?.text = settingList[senderPage ?? -1].menu?[indexPath.row]
        
        if ((indexPath.row) == UserDefaults.standard.integer(forKey: saveKey)) && (senderPage != 3) {
            cell.accessoryType = .checkmark
        }
        
        if senderPage == 3 {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}
