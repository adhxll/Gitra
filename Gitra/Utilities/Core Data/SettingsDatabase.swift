//  Settings.swift
//  Gitra
//
//  Created by Gilang Adrian on 11/06/21.
//

import Foundation

enum TypeSetting {
    case toggle
    case click
    case description
}

struct SettingsType {
    var titleSettings : String?
    var type : TypeSetting?
    var selected : Int?
    var menu : [String]?
}

class SettingsDatabase{
    static let shared = SettingsDatabase()
    
    var inputModes: Int?
    var welcomeScreen: Int?
    var inputCommand: Int?
    var chordSpeed: Int?
    
    private var settings = [SettingsType]()
    
    init() {
        self.inputModes = UserDefaults.standard.integer(forKey: "inputMode")
        self.welcomeScreen = UserDefaults.standard.integer(forKey: "welcomeScreen")
        self.inputCommand = UserDefaults.standard.integer(forKey: "inputCommand")
        self.chordSpeed = UserDefaults.standard.integer(forKey: "chordSpeed")
        
        settings = [
//            SettingsType(titleSettings: "Chord Input Mode", type: .description, selected: inputModes, menu: ["Voice Command", "Picker"]),
                    SettingsType(titleSettings: "Welcome Screen", type: .toggle, selected: welcomeScreen),
                    SettingsType(titleSettings: "Input Command Guides", type: .toggle, selected: inputCommand),
                    SettingsType(titleSettings: "Chord Speed", type: .description, selected: chordSpeed, menu: ["Slow", "Normal", "Fast"]),
                    SettingsType(titleSettings: "Instructions", type: .click, menu: ["Voice Command Mode", "Picker Mode", "Automatic Tuner"])]
    }
    
    func reloadDatabase(){
        self.inputModes = UserDefaults.standard.integer(forKey: "inputMode")
        self.welcomeScreen = UserDefaults.standard.integer(forKey: "welcomeScreen")
        self.inputCommand = UserDefaults.standard.integer(forKey: "inputCommand")
        self.chordSpeed = UserDefaults.standard.integer(forKey: "chordSpeed")
        
        settings = [
//            SettingsType(titleSettings: "Chord Input Mode", type: .description, selected: inputModes, menu: ["Voice Command", "Picker"]),
                    SettingsType(titleSettings: "Welcome Screen", type: .toggle, selected: welcomeScreen),
                    SettingsType(titleSettings: "Input Command Guides", type: .toggle, selected: inputCommand),
                    SettingsType(titleSettings: "Chord Speed", type: .description, selected: chordSpeed, menu: ["Slow", "Normal", "Fast"]),
                    SettingsType(titleSettings: "Instructions", type: .click, menu: ["Voice Command Mode", "Picker Mode", "Automatic Tuner"])]
    }
    
    func getSettings() -> [SettingsType] {
        return settings
    }
}
