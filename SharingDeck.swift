//
//  SharingDeck.swift
//  fark3230_a3
//
//  Created by Tyler Farkas on 2018-02-08.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import Foundation

class SharingDeck {
    static let sharedDeck = SharingDeck()
    let fileName = "cards.archive"
    
    private let rootKey = "rootKey"
    private var deck : Deck?
    
    func dataFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.appendingPathComponent(fileName) as String
    }
    
    func loadDeck(){
        let filePath = self.dataFilePath()
        if(FileManager.default.fileExists(atPath: filePath)){
            let data = NSMutableData(contentsOfFile: filePath)!
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)
            deck = unarchiver.decodeObject(forKey: rootKey) as? Deck
            unarchiver.finishDecoding()
        }
    }
    
    
    func getDeck()->Deck?{
        return deck
    }
    
    func setDeck(newDeck: Deck){
        deck = newDeck
    }
    
    func saveDeck(){
        let filePath = self.dataFilePath()
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(deck, forKey: rootKey)
        archiver.finishEncoding()
        data.write(toFile:filePath,atomically: true)
    }

}
