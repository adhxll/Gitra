//
//  ChordPickerViewModel.swift
//  Gitra
//
//  Created by Yahya Ayyash Asaduddin on 16/04/22.
//

import Foundation

class ChordPickerViewModel {
    
    private let noteData: [ChordBase] = Database.shared.getNote()
    private let chordData: [ChordBase] = Database.shared.getChord()
    
    public private(set) var selectedChord: PickerItemModel
    
    init() {
        self.selectedChord = PickerItemModel();
    }
}

extension ChordPickerViewModel {
    // MARK: - Used for generating UIPickerView data
    func noteCount() -> Int {
        return noteData.count
    }
    
    func qualityCount() -> Int {
        return chordData.count
    }
    
    func tensionCount(for selected: Int) -> Int {
        return chordData[selected].child?.count ?? 0
    }
    
    func noteForRow(at index: Int) -> PickerItemModel {
        var item: PickerItemModel = PickerItemModel()
        item.title = noteData[index].value
        item.apiFormat = noteData[index].apiFormat
        item.accessibiltyLabel = "Chord Root, " + noteData[index].accessibility + "."
        return item
    }
    
    // TODO: Find a way to bind quality & tension
    func qualityForRow(at index: Int) -> PickerItemModel {
        var item: PickerItemModel = PickerItemModel()
        item.title = chordData[index].value
        item.apiFormat = chordData[index].apiFormat
        item.accessibiltyLabel = "Chord Type, " + chordData[index].accessibility + "."
        return item
    }
    
    func tensionForRow(at index: Int, for selected: Int) -> PickerItemModel {
        var item: PickerItemModel = PickerItemModel()
        guard let childTension = chordData[selected].child?[index] else { return item }
        
        item.title = childTension.value
        item.apiFormat = childTension.apiFormat
        item.accessibiltyLabel = "Chord Tension, " + childTension.accessibility + "."
        return item
    }
    
    // MARK: - Generating selected chord
    func transformChordToAPI(root: String, quality: String, tension: String) -> String {
        if quality == "maj" && tension.isEmpty {
            return root
        } else if quality == "maj" && tension.isNotEmpty {
            return root + "_" + tension
        }
        return root + "_" + quality + tension
    }
    
    func generateSelectedChord(root: Int, quality: Int, tension: Int) -> PickerItemModel {
        var item = PickerItemModel()
        let rootItem = noteForRow(at: root)
        let qualityItem = qualityForRow(at: quality)
        let tensionItem = tensionForRow(at: tension, for: quality)
        item.title = rootItem.title + qualityItem.title + tensionItem.title
        item.apiFormat = transformChordToAPI(root: rootItem.apiFormat, quality: qualityItem.apiFormat, tension: tensionItem.apiFormat)
        item.accessibiltyLabel = [rootItem.accessibiltyLabel, qualityItem.accessibiltyLabel, tensionItem.accessibiltyLabel].joined(separator: " ")
        
        // Store last generated chord
        selectedChord = item;
        
        return item
    }
}

// Might not be needed, need further discussion
struct PickerItemModel {
    var title: String
    var apiFormat: String
    var accessibiltyLabel: String
    
    init() {
        self.title = ""
        self.apiFormat = ""
        self.accessibiltyLabel = ""
    }
}

