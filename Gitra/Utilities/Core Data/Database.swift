//
//  Database.swift
//  Gitra
//
//  Created by Yahya Ayyash on 09/06/21.
//

import Foundation

class Database {
    
    static let shared = Database()
    
    private var noteList = [String]()
    private var chordList = [ChordQuality]()
    private var guitarNotes = [[String]]()
    
    init(){
    }
    
    func seedNote() {
        noteList = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    }
    
    func seedChord() {
        chordList.append(ChordQuality(quality: "-", tension: ["-", "6", "6/9", "7", "7♯5", "7♭5", "7♯9", "7♭9", "11"]))
        chordList.append(ChordQuality(quality: "Major", tension: ["-", "6", "6/9", "7", "9", "11"]))
        chordList.append(ChordQuality(quality: "Minor", tension: ["-", "6", "6/9", "7", "9", "11"]))
        chordList.append(ChordQuality(quality: "Add", tension: ["9", "11"]))
        chordList.append(ChordQuality(quality: "Sus", tension: ["2", "4"]))
        chordList.append(ChordQuality(quality: "Dim", tension: ["-"]))
        chordList.append(ChordQuality(quality: "Aug", tension: ["-"]))
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
    
    func getNote() -> [String] {
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
