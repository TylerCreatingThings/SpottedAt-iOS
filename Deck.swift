//
//  Deck.swift
//  fark3230_a2
//
//  Created by Tyler Farkas on 2018-01-29.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import Foundation
import UIKit

class Deck: NSObject, NSCoding{
    private var cards = [Card]()
    private var current: Int=0
    private var maxCount: Int=0
    private var time: String?
    let deckKey = "deckKey"
    let indexKey = "indexKey"
    let timeKey = "timeKey"
    
    
    override init(){
        super.init()
        initDeck()
    }
    
    func initDeck(){
        
        //addCard(newQuestion: "What city was I born in?", newAnswer: "Toronto", newImage: UIImage(named: "Q1")!)
        //addCard(newQuestion: "What do humans use to see?", newAnswer: "Eyes", newImage: UIImage(named: "Q2")!)
        //addCard(newQuestion: "What do cars drive on?", newAnswer: "A road", newImage: UIImage(named: "Q3")!)
        //addCard(newQuestion: "How do we locate where we are?", newAnswer: "Look at a map.", newImage: UIImage(named: "Q4")!)
        
        
    }
    
    func getLength()->Int{
        return cards.count
    }
    
    func setTime(timeVal: String){
        time = timeVal
    }
    
    func getTime()->String{
        return time!
    }
    
    func next(){
        if(current < maxCount-1 ){
            current+=1
        }
        else{
            current = 0
        }
    }
    
    func isEmpty()->Bool{
        if(cards.count>0){
            return false
        }
        else{
            return true
        }
    }
    
    func card()->Card{
        print(current)
        let currentCard:Card? = cards[current]
        return currentCard!
    }
    
    func addCard(newQuestion: String, newAnswer: String, newImage: UIImage, newUrl: String){
        let newCard = Card(image:newImage,question:newQuestion,answer: newAnswer, url: newUrl)
        cards.append(newCard!)
        maxCount+=1
    }
    
    func deleteCurrentCard(){
        cards.remove(at: current)
        maxCount-=1
    }
    
    func setCard(index: Int){
        current = index
    }
    
    func getElementAtIndex(index: Int)->Card{
        return cards[index]
    }
    
    
    func getCard() -> Int {
        let index:Int = current
        return index
    }
    
    
    required convenience init?(coder decoder: NSCoder){
        self.init()
        cards = (decoder.decodeObject(forKey: deckKey) as? [Card])!
        
        current = (decoder.decodeInteger(forKey: indexKey))
        
        time = (decoder.decodeObject(forKey: timeKey) as? String)
    }
    
    func encode(with acoder: NSCoder){
        acoder.encode(cards,forKey:deckKey)
        acoder.encode(current,forKey: indexKey)
        acoder.encode(time,forKey: timeKey)

    }
    
}
