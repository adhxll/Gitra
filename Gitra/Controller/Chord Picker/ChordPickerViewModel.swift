//
//  ChordPickerViewModel.swift
//  Gitra
//
//  Created by Yahya Ayyash Asaduddin on 16/04/22.
//

import Foundation
import Combine

class ChordPickerViewModel {
    
    private let noteData: [ChordBase] = Database.shared.getNote()
    private let chordData: [ChordQuality] = Database.shared.getChord()
    
    @Published var root: Int = 0
    @Published var quality: Int = 0
    @Published var tension: Int = 0
    
    var chordOutput: AnyPublisher<ChordBase, Never> {
        return Publishers.CombineLatest3($root, $quality, $tension)
            .map { root, quality, tension in
                var chordBase: ChordBase = ChordBase()
                let rootChord: ChordBase = self.noteData[root]
                let qualityChord: ChordQuality = self.chordData[quality]
                let tensionChord: ChordTension = self.chordData[quality].tension[tension]
                chordBase.accessibility = [rootChord.accessibility, qualityChord.accessibility, tensionChord.accessibility].joined(separator: "")
                chordBase.apiFormat = [rootChord.apiFormat, qualityChord.apiFormat, tensionChord.apiFormat].joined(separator: "")
                return chordBase
            }.eraseToAnyPublisher()
    }
    
    init() {}
    
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
        return chordData[selected].tension.count
    }
    
    func noteForRow(at index: Int) -> PickerItemModel {
        var item: PickerItemModel = PickerItemModel()
        item.title = noteData[index].value
        item.accessibiltyLabel = "Chord Root, " +  noteData[index].accessibility + "."
        return item
    }
    
    // TODO: Find a way to bind quality & tension
    func qualityForRow(at index: Int) -> PickerItemModel {
        var item: PickerItemModel = PickerItemModel()
        item.title = chordData[index].value
        item.accessibiltyLabel = "Chord Type, " +  chordData[index].accessibility + "."
        return item
    }
    
    func tensionForRow(at index: Int, for selected: Int) -> PickerItemModel {
        var item: PickerItemModel = PickerItemModel()
        item.title = chordData[selected].tension[index].value
        item.accessibiltyLabel = "Chord Tension, " +  chordData[selected].tension[index].accessibility + "."
        return item
    }
    
    // MARK: - Generating selected chord
    func generateSelectedChord(root: Int, quality: Int, tension: Int) -> PickerItemModel {
        var item = PickerItemModel()
        let rootItem = noteForRow(at: root)
        let qualityItem = qualityForRow(at: quality)
        let tensionItem = tensionForRow(at: tension, for: quality)
        item.title = rootItem.title + qualityItem.title + tensionItem.title
        item.accessibiltyLabel = [rootItem.accessibiltyLabel, qualityItem.accessibiltyLabel, tensionItem.accessibiltyLabel].joined(separator: " ")
        return item
    }
}

// Might not be needed, need further discussion
struct PickerItemModel {
    var title: String
    var accessibiltyLabel: String
    
    init() {
        self.title = ""
        self.accessibiltyLabel = ""
    }
}

