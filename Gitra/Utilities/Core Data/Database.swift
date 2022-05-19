//
//  Database.swift
//  Gitra
//
//  Created by Yahya Ayyash on 09/06/21.
//

import Foundation

class Database {
    
    static let shared = Database()
    
    private var noteList = [ChordBase]()
    private var chordList = [ChordBase]()
    private var guitarNotes = [[String]]()
    
    init(){
    }
    
    // MARK: - Seeder Methods
    func seedNote() {
        noteList.append(ChordBase(value: "C", accessibility: "C", apiFormat: "C"))
        noteList.append(ChordBase(value: "C♯", accessibility: NSLocalizedString("chord-base.c-sharp", comment: ""), apiFormat: "Db"))
        noteList.append(ChordBase(value: "D", accessibility: "D", apiFormat: "D"))
        noteList.append(ChordBase(value: "D♯", accessibility: NSLocalizedString("chord-base.d-sharp", comment: ""), apiFormat: "Eb"))
        noteList.append(ChordBase(value: "E", accessibility: "E", apiFormat: "E"))
        noteList.append(ChordBase(value: "F", accessibility: "F", apiFormat: "F"))
        noteList.append(ChordBase(value: "F♯", accessibility: NSLocalizedString("chord-base.f-sharp", comment: ""), apiFormat: "Gb"))
        noteList.append(ChordBase(value: "G", accessibility: "G", apiFormat: "G"))
        noteList.append(ChordBase(value: "G♯", accessibility: NSLocalizedString("chord-base.g-sharp", comment: ""), apiFormat: "Ab"))
        noteList.append(ChordBase(value: "A", accessibility: "A", apiFormat: "A"))
        noteList.append(ChordBase(value: "A♯", accessibility: NSLocalizedString("chord-base.a-sharp", comment: ""), apiFormat: "Bb"))
        noteList.append(ChordBase(value: "B", accessibility: "B", apiFormat: "B"))
    }
    
    func seedChord() {
        let empty = ChordBase(value: "-", accessibility: "", apiFormat: "")
        let second = ChordBase(value: "2", accessibility: NSLocalizedString("chord-tension.second", comment: ""), apiFormat: "2")
        let fourth = ChordBase(value: "4", accessibility: NSLocalizedString("chord-tension.fourth", comment: ""), apiFormat: "4")
        let sixth = ChordBase(value: "6", accessibility: NSLocalizedString("chord-tension.sixth", comment: ""), apiFormat: "6")
        let sixthNinth = ChordBase(value: "6/9", accessibility: NSLocalizedString("chord-tension.sixth-ninth", comment: ""), apiFormat: "69")
        let seventh = ChordBase(value: "7", accessibility: NSLocalizedString("chord-tension.seventh", comment: ""), apiFormat: "7")
        let sevenSharpFifth = ChordBase(value: "7♯5", accessibility: NSLocalizedString("chord-tension.seventh-sharp-fifth", comment: ""), apiFormat: "7#5")
        let sevenFlatFifth = ChordBase(value: "7♭5", accessibility: NSLocalizedString("chord-tension.seventh-flat-fifth", comment: ""), apiFormat: "7b5")
        let sevenSharpNinth = ChordBase(value: "7♯9", accessibility: NSLocalizedString("chord-tension.seventh-sharp-ninth", comment: ""), apiFormat: "7#9")
        let sevenFlatNinth = ChordBase(value: "7♭9", accessibility: NSLocalizedString("chord-tension.seventh-flat-ninth", comment: ""), apiFormat: "7b9")
        let ninth = ChordBase(value: "9", accessibility: NSLocalizedString("chord-tension.ninth", comment: ""), apiFormat: "9")
        let eleventh = ChordBase(value: "11", accessibility: NSLocalizedString("chord-tension.eleventh", comment: ""), apiFormat: "11")
        
        chordList.append(ChordBase(value: "-",
                                   accessibility: "",
                                   apiFormat: "",
                                   child: [empty, sixth, sixthNinth, seventh, sevenSharpFifth, sevenFlatFifth, sevenSharpNinth, sevenFlatNinth, eleventh]))
        chordList.append(ChordBase(value: "Major",
                                   accessibility: NSLocalizedString("chord-quality.major", comment: ""),
                                   apiFormat: "maj",
                                   child: [empty, sixth, sixthNinth, seventh, ninth, eleventh]))
        chordList.append(ChordBase(value: "Minor",
                                   accessibility: NSLocalizedString("chord-quality.minor", comment: ""),
                                   apiFormat: "m",
                                   child: [empty, sixth, sixthNinth, seventh, ninth, eleventh]))
        chordList.append(ChordBase(value: "Add",
                                   accessibility: NSLocalizedString("chord-quality.add", comment: ""),
                                   apiFormat: "add",
                                   child: [ninth, eleventh]))
        chordList.append(ChordBase(value: "Sus",
                                   accessibility: NSLocalizedString("chord-quality.sus", comment: ""),
                                   apiFormat: "sus",
                                   child: [second, fourth]))
        chordList.append(ChordBase(value: "Dim",
                                   accessibility: NSLocalizedString("chord-quality.dim", comment: ""),
                                   apiFormat: "dim",
                                   child: [empty]))
        chordList.append(ChordBase(value: "Aug",
                                   accessibility: NSLocalizedString("chord-quality.aug", comment: ""),
                                   apiFormat: "aug",
                                   child: [empty]))
    }
    
    func seedGuitarNotes() {
        guitarNotes.append(["E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5", "C6"])
        guitarNotes.append(["B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5"])
        guitarNotes.append(["G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5"])
        guitarNotes.append(["D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4"])
        guitarNotes.append(["A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4"])
        guitarNotes.append(["E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C3"])
    }
    
    // MARK: - Public Methods
    func seedData() {
        seedNote()
        seedChord()
        seedGuitarNotes()
    }
    
    func getNote() -> [ChordBase] {
        return noteList
    }
    
    func getChord() -> [ChordBase] {
        return chordList
    }
    
    func getNoteList() -> [[String]] {
        return guitarNotes
    }
    
    func getGuitarNote( _ string: Int, _ fret: Int) -> String {
        return Database.shared.getNoteList()[string][fret]
    }
}
