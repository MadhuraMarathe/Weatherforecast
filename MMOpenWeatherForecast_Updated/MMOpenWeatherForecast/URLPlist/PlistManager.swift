//
//  Plist.swift
//  MMOpenWeatherForecast
//
//  Created by Apple3 on 28/04/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import Foundation

struct PlistManager {
    
    // MARK: - Enum.
    enum PlistError: Error {
        case FileNotWritten
        case FileDoesNotExist
    }
    // MARK: - Variables.
    private let name:String // plist name
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
        return path
    }
    var destPath:String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    // MARK: - Functions.
    init?(name:String) {
        if name.isEmpty { return nil }
        self.name = name
    }
    
    // save it to the documents directory
    func save() {
        let fileManager = FileManager.default
        guard let source = sourcePath , let destination = destPath , fileManager.fileExists(atPath: source)
            else { return }
        if !fileManager.fileExists(atPath: destination) {
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func addValuesToPlistFile(dictionary:NSDictionary) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !dictionary.write(toFile: destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
}
