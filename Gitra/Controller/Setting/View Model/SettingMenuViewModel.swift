//
//  SettingViewModel.swift
//  Gitra
//
//  Created by Yahya Ayyash on 05/04/22.
//

import Foundation

class SettingViewModel {
    var data: SettingMenuViewModel
    
    init() {
        data = SettingMenuViewModel(setting: SettingsDatabase.shared.getSettings())
    }
}

extension SettingViewModel {
    func settingListCount() -> Int {
        return data.child?.count ?? 0
    }
    
    func settingForRow(at index: Int) -> SettingMenuViewModel {
        return data.child?[index] ?? SettingMenuViewModel(setting: SettingMenu(title: "Out of range.", type: .none))
    }
    
    func toggleSettings(value: Int, forKey key: SettingKey) {
        // TODO: Move User Defaults
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}

struct SettingMenuViewModel {
    private let setting: SettingMenu
    
    init(setting: SettingMenu) {
        self.setting = setting
    }
}

extension SettingMenuViewModel {
    
    var pageTitle: String {
        return setting.pageTitle ?? setting.title
    }
    
    var title: String {
        return setting.title
    }
    
    var type: SettingType {
        return setting.type
    }
    
    var value: Int {
        // TODO: Move User Defaults
        return UserDefaults.standard.integer(forKey: setting.saveKey?.rawValue ?? "")
    }
    
    var child: [SettingMenuViewModel]? {
        return setting.child?.map{ SettingMenuViewModel.init(setting: $0) }
    }
    
    var key: SettingKey? {
        return setting.saveKey
    }
    
    // For setting menu with 'option' type
    // childTitle should show the choosen option based on the data that was saved on UserDefaults
    var childTitle: String {
        // TODO: Implement condition for info menu type
        if setting.type == .info { return "\(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))" }
        return setting.child?[value].title ?? ""
    }
    
    var hasChild: Bool {
        return setting.child?.count ?? 0 > 0
    }
    
    var header: String {
        return setting.sectionHeader ?? ""
    }
    
    var footer: String {
        return setting.sectionFooter ?? ""
    }
    
}
