//  Settings.swift
//  Gitra
//
//  Created by Gilang Adrian on 11/06/21.
//

enum SettingKey: String, CaseIterable {
    case inputMode
    case welcomeScreen
    case inputCommand
    case chordSpeed
    
    // Needed for UISwitch Tag
    var index: Int {
        var index = 0
        for (_index, item) in SettingKey.allCases.enumerated() where item == self { index = _index }
        return index
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
        SettingMenu(title: "Slow", type: .checkmark),
        SettingMenu(title: "Normal", type: .checkmark),
        SettingMenu(title: "Fast", type: .checkmark)
    ]
    
    private let instructionChild: [SettingMenu] = [
        SettingMenu(title: "Voice Command Mode",
                    type: .disclosure,
                    child: [
                        SettingMenu(title: "Wait until you can hear the cue to speak sound.", type: .description),
                        SettingMenu(title: "Say which chord do you want to play (e.g. C Major), you will be directed into the chord detail page.", type: .description),
                        SettingMenu(title: "On the chord detail page, say 'Next' if you want to go to the next string, and 'Repeat' if you want to repeat the note sound.", type: .description),
                        SettingMenu(title: "There is a toolbar with 'Previous', 'Next', and 'Repeat' button on the bottom of the screen.", type: .description)
                    ]),
        SettingMenu(title: "Picker Mode",
                    type: .disclosure,
                    child: [
                        SettingMenu(title: "If you are using picker mode, on the main page there will be a picker which you can adjust to find the chord you are looking for.", type: .description),
                        SettingMenu(title: "There are 3 section that you can adjust, roots, quality, and tension.", type: .description),
                        SettingMenu(title: "On the chord detail page, say 'Next' if you want to go to the next string, and 'Repeat' if you want to repeat the note sound.", type: .description),
                        SettingMenu(title: "You can adjust the picker by swiping up or down on each section.", type: .description)
                    ]),
        SettingMenu(title: "Automatic Tuner",
                    type: .disclosure,
                    child: [
                        SettingMenu(title: "Press the start button in the middle of the screen to start the tuner.", type: .description),
                        SettingMenu(title: "Pluck a string and hear the instructions on how to tune the selected string.", type: .description),
                        SettingMenu(title: "Tune the string until you hear the sound cue, indicating that the string is tuned.", type: .description),
                        SettingMenu(title: "Press the stop button in the middle of the screen to turn off the tuner.", type: .description)
                    ])]
    
    init() {
        settings = SettingMenu(title: "Settings", type: .none, child: [
            SettingMenu(title: "Welcome Screen", type: .toggle, saveKey: .welcomeScreen),
            SettingMenu(title: "Input Command Guide", type: .toggle, saveKey: .inputCommand),
            SettingMenu(title: "Chord Speed", type: .options, sectionFooter: "Determine the chord playback speed for the instruction mode. The default value is normal.", child: chordSpeedChild, saveKey: .chordSpeed),
            SettingMenu(title: "Instructions", type: .disclosure, child: instructionChild),
            SettingMenu(title: "App Version", type: .info)
        ])
    }
}

extension SettingsDatabase {
    
    func getSettings() -> SettingMenu {
        return settings
    }
    
}
