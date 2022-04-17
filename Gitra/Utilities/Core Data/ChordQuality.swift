//
//  ChordQuality.swift
//  Gitra
//
//  Created by Yahya Ayyash on 09/06/21.
//

import Foundation

protocol ChordFormatProtocol {
    var value: String { get set }
    var accessibility: String { get set }
    var apiFormat: String { get set }
}

struct ChordBase: ChordFormatProtocol {
    var value: String = ""
    var accessibility: String = ""
    var apiFormat: String = ""
}

struct ChordQuality: ChordFormatProtocol {
    var value: String
    var accessibility: String
    var apiFormat: String
    var tension : [ChordTension]
}

struct ChordTension: ChordFormatProtocol {
    var value: String
    var accessibility: String
    var apiFormat: String
}
