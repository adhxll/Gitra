//
//  SettingViewController.swift
//  Gitra
//
//  Created by Christopher Teddy  on 07/06/21.
//

import UIKit

class SettingViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var settingsList = SettingsDatabase.shared.getSettings()
    var sender: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SettingsDatabase.shared.reloadDatabase()
        settingsList = SettingsDatabase.shared.getSettings()
        tableView.reloadData()
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? SettingListViewController
        destination?.senderPage = self.sender
    }
}

extension SettingViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Identify the sender
        sender = indexPath.row
        
        if (indexPath.row == 2) || (indexPath.row == 3) {
            performSegue(withIdentifier: "SettingsListSegue", sender: nil)
        }
    }
}

extension SettingViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingsTableViewCell")
        
        cell.textLabel?.text = settingsList[indexPath.row].titleSettings
        let selected = settingsList[indexPath.row].selected
        
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = .ColorLibrary.yellowAccent
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        if settingsList[indexPath.row].type == .click{
            cell.accessoryType = .disclosureIndicator
        } else if settingsList[indexPath.row].type == .toggle{
            cell.accessoryView = switchView
            if selected == 1{
                switchView.setOn(true, animated: true)
            } else {
                switchView.setOn(false, animated: true)
            }
        } else if settingsList[indexPath.row].type == .description{
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = settingsList[indexPath.row].menu?[selected!]
        }
        
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch!){
        let status = sender.isOn ? 1 : 0
        
        if sender.tag == 0{
            UserDefaults.standard.set(status, forKey: "welcomeScreen")
        } else {
            UserDefaults.standard.set(status, forKey: "inputCommand")
        }
    }
}
