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
    private var chordList = [ChordQuality]()
    private var guitarNotes = [[String]]()
    
    init(){
    }
    
    func seedNote() {
        noteList.append(ChordBase(value: "C", accessibility: "C", apiFormat: "C"))
        noteList.append(ChordBase(value: "C♯", accessibility: "C Sharp", apiFormat: "Db"))
        noteList.append(ChordBase(value: "D", accessibility: "D", apiFormat: "D"))
        noteList.append(ChordBase(value: "D♯", accessibility: "D Sharp", apiFormat: "Eb"))
        noteList.append(ChordBase(value: "E", accessibility: "E", apiFormat: "E"))
        noteList.append(ChordBase(value: "F", accessibility: "F", apiFormat: "F"))
        noteList.append(ChordBase(value: "F♯", accessibility: "F Sharp", apiFormat: "Gb"))
        noteList.append(ChordBase(value: "G", accessibility: "G", apiFormat: "G"))
        noteList.append(ChordBase(value: "G♯", accessibility: "G Sharp", apiFormat: "Ab"))
        noteList.append(ChordBase(value: "A", accessibility: "A", apiFormat: "A"))
        noteList.append(ChordBase(value: "A♯", accessibility: "A Sharp", apiFormat: "Bb"))
        noteList.append(ChordBase(value: "B", accessibility: "B", apiFormat: "B"))
    }
    
    func seedChord() {
        let empty = ChordTension(value: "-", accessibility: "", apiFormat: "")
        let second = ChordTension(value: "2", accessibility: "Second", apiFormat: "2")
        let fourth = ChordTension(value: "4", accessibility: "Fourth", apiFormat: "4")
        let sixth = ChordTension(value: "6", accessibility: "Sixth", apiFormat: "6")
        let sixthNinth = ChordTension(value: "6", accessibility: "Sixth Nine", apiFormat: "69")
        let seventh = ChordTension(value: "7", accessibility: "Seventh", apiFormat: "7")
        let sevenSharpFifth = ChordTension(value: "7♯5", accessibility: "Seventh Sharp Fifth", apiFormat: "7#5")
        let sevenFlatFifth = ChordTension(value: "7♭5", accessibility: "Seventh Flat Fifth", apiFormat: "7b5")
        let sevenSharpNinth = ChordTension(value: "7♯9", accessibility: "Seventh Sharp Ninth", apiFormat: "7#9")
        let sevenFlatNinth = ChordTension(value: "7♭9", accessibility: "Seventh Flat Ninth", apiFormat: "7b9")
        let ninth = ChordTension(value: "9", accessibility: "Ninth", apiFormat: "9")
        let eleventh = ChordTension(value: "11", accessibility: "Eleventh", apiFormat: "11")
        
        chordList.append(ChordQuality(value: "-",
                                      accessibility: "",
                                      apiFormat: "",
                                      tension: [empty, sixth, sixthNinth, seventh, sevenSharpFifth, sevenFlatFifth, sevenSharpNinth, sevenFlatNinth, eleventh]))
        chordList.append(ChordQuality(value: "Major",
                                      accessibility: "Major",
                                      apiFormat: "",
                                      tension: [empty, sixth, sixthNinth, seventh, ninth, eleventh]))
        chordList.append(ChordQuality(value: "Minor",
                                      accessibility: "Minor",
                                      apiFormat: "m",
                                      tension: [empty, sixth, sixthNinth, seventh, ninth, eleventh]))
        chordList.append(ChordQuality(value: "Add",
                                      accessibility: "Add",
                                      apiFormat: "add",
                                      tension: [ninth, eleventh]))
        chordList.append(ChordQuality(value: "Sus",
                                      accessibility: "Suspended",
                                      apiFormat: "sus",
                                      tension: [second, fourth]))
        chordList.append(ChordQuality(value: "Dim",
                                      accessibility: "Diminished",
                                      apiFormat: "dim",
                                      tension: [empty]))
        chordList.append(ChordQuality(value: "Aug",
                                      accessibility: "Augmented",
                                      apiFormat: "aug",
                                      tension: [empty]))
    }
    
    func seedGuitarNotes() {
        guitarNotes.append(["E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5", "C6"])
        guitarNotes.append(["B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5"])
        guitarNotes.append(["G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5"])
        guitarNotes.append(["D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4"])
        guitarNotes.append(["A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4"])
        guitarNotes.append(["E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C3"])
    }
    
    func seedData() {
        seedNote()
        seedChord()
        seedGuitarNotes()
    }
    
    func getNote() -> [ChordBase] {
        return noteList
    }
    
    func getChord() -> [ChordQuality] {
        return chordList
    }
    
    func getNoteList() -> [[String]] {
        return guitarNotes
    }
    
    func getGuitarNote( _ string: Int, _ fret: Int) -> String {
        return Database.shared.getNoteList()[string][fret]
    }
}
