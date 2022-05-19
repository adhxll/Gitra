//  Settings.swift
//  Gitra
//
//  Created by Gilang Adrian on 11/06/21.
//

import Foundation

enum SettingKey: String, CaseIterable {
    case inputMode
    case welcomeScreen
    case inputCommand
    case chordSpeed
    
    // Needed for UISwitch Tag
    var index: Int {
        for (index, item) in SettingKey.allCases.enumerated() where item == self { return index }
        return 0
    }
}

enum SettingType {
    case toggle
    case disclosure
    case options
    case checkmark
    case description
    case info
    case none
}

struct SettingMenu {
    let title: String
    let type: SettingType
    
    var pageTitle: String?
    var sectionHeader: String?
    var sectionFooter: String?
    
    var child: [SettingMenu]?
    var saveKey: SettingKey?
    var value: Int?
}

class SettingsDatabase {
    static let shared = SettingsDatabase()
    
    private var settings: SettingMenu
    
    private let chordSpeedChild: [SettingMenu] = [
        SettingMenu(title: NSLocalizedString("settings.menu-speed.slow", comment: ""), type: .checkmark),
        SettingMenu(title: NSLocalizedString("settings.menu-speed.normal", comment: ""), type: .checkmark),
        SettingMenu(title: NSLocalizedString("settings.menu-speed.fast", comment: ""), type: .checkmark)
    ]
    
    private let instructionChild: [SettingMenu] = [
        SettingMenu(title: NSLocalizedString("settings.menu-instruction-voiceCommandMode.title", comment: ""),
                    type: .disclosure,
                    child: [
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-voiceCommandMode.first-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-voiceCommandMode.second-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-voiceCommandMode.third-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-voiceCommandMode.fourth-instruction", comment: ""), type: .description)
                    ]),
        SettingMenu(title: NSLocalizedString("settings.menu-instruction-pickerMode.title", comment: ""),
                    type: .disclosure,
                    child: [
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-pickerMode.first-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-pickerMode.second-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-pickerMode.third-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-pickerMode.fourth-instruction", comment: ""), type: .description)
                    ]),
        SettingMenu(title: NSLocalizedString("settings.menu-instruction-automaticTuner.title", comment: ""),
                    type: .disclosure,
                    child: [
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-automaticTuner.first-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-automaticTuner.second-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-automaticTuner.third-instruction", comment: ""), type: .description),
                        SettingMenu(title: NSLocalizedString("settings.menu-instruction-automaticTuner.fourth-instruction", comment: ""), type: .description)
                    ])]
    
    init() {
        settings = SettingMenu(title: NSLocalizedString("settings.menu-main.title", comment: ""), type: .none, child: [
            SettingMenu(title: NSLocalizedString("settings.menu-welcome.title", comment: ""), type: .toggle, saveKey: .welcomeScreen),
            SettingMenu(title: NSLocalizedString("settings.menu-command.title", comment: ""), type: .toggle, saveKey: .inputCommand),
            SettingMenu(title: NSLocalizedString("settings.menu-speed.title", comment: ""), type: .options, sectionFooter: NSLocalizedString("settings.menu-speed.footer", comment: ""), child: chordSpeedChild, saveKey: .chordSpeed),
            SettingMenu(title: NSLocalizedString("settings.menu-instructions.title", comment: ""), type: .disclosure, child: instructionChild),
            SettingMenu(title: NSLocalizedString("settings.menu-appVersion.title", comment: ""), type: .info)
        ])
    }
}

extension SettingsDatabase {
    
    func getSettings() -> SettingMenu {
        return settings
    }
    
}
