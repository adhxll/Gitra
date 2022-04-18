//
//  SettingViewController.swift
//  Gitra
//
//  Created by Christopher Teddy  on 07/06/21.
//

import UIKit

class SettingViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    var settingVM: SettingViewModel
    
    init(settingVM: SettingViewModel) {
        self.settingVM = settingVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func setupUI() {
        // Main View
        title = settingVM.data.pageTitle
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Table View
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func clearAccecoryType() {
        // Deselect all row to remove checkmark
        for i in 0..<settingVM.settingListCount() {
            tableView.cellForRow(at: [0,i])?.accessoryType = .none
        }
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
        let status = sender.isOn ? 1 : 0
        settingVM.toggleSettings(value: status, forKey: .allCases[sender.tag])
    }
}

// MARK: - TableView Delegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        let currCell = settingVM.settingForRow(at: indexPath.row)
        
        // If currentCell has child
        if currCell.hasChild {
            let nextVM = settingVM.settingForRow(at: indexPath.row)
            let nextVVM = SettingViewModel()
            nextVVM.data = nextVM
            let nextVC = SettingViewController(settingVM: nextVVM)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
        // If current page type is options (selected setting menu) and current cell type is checkmark
        if settingVM.data.type == .options && currCell.type == .checkmark {
            clearAccecoryType()
            cell?.accessoryType = .checkmark
            // TODO: Move User Defaults
            UserDefaults.standard.set(indexPath.row, forKey: settingVM.data.key?.rawValue ?? "")
        }
    }
}

// MARK: - TableView Datasource
extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingVM.settingListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Store identifier in enum
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingsTableViewCell")
        let currCell = settingVM.settingForRow(at: indexPath.row)
        let currCellTag = currCell.key?.index ?? -1
        
        cell.textLabel?.text = currCell.title
        
        switch currCell.type {
        case .disclosure:
            cell.accessoryType = .disclosureIndicator
        case .options:
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = currCell.childTitle
        case .toggle:
            let customSwitch = CustomSwitch()
            customSwitch.setupSwitch(self, tag: currCellTag, action: #selector(switchChanged))
            customSwitch.setOn(currCell.value == 1, animated: true)
            cell.accessoryView = customSwitch
        case .checkmark:
            cell.accessoryType = settingVM.data.value == indexPath.row ? .checkmark : .none
        case .description:
            guard let descCell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
            descCell.setupContent(for: indexPath.row + 1,text: currCell.title)
            return descCell
        case .info:
            cell.detailTextLabel?.text = currCell.childTitle
        case .none:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingVM.data.header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return settingVM.data.footer
    }
}
