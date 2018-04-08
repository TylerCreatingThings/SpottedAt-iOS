//
//  Card.swift
//  fark3230_a2
//
//  Created by Tyler Farkas on 2018-01-29.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import Foundation
import UIKit
import os

class Card: NSObject {
    private let image:UIImage?
    private let question:String
    private let answer:String
    private let url:String
    private let latitude:Double
    private let longitude:Double
    private let imageID:String
    
    init?(image: UIImage?, question: String, answer: String, url: String,latitude: Double, longitude: Double, imageID: String){
        guard !question.isEmpty else{
            return nil
        }
        
        guard !answer.isEmpty else{
            return nil
        }
        self.imageID = imageID
        self.image = image
        self.question = question
        self.answer = answer
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
        
    }

    func getImage()->UIImage{
        return image!
    }
    
    func getQuestion()->String{
        return question
    }
    
    func getAnswer()->String{
        return answer
    }
    
    func getUrl()->String{
        return url
    }
    func getLatitude()->Double{
        return latitude
    }
    func getLongitude()->Double{
        return longitude
    }
    
    func getImageID()->String{
        return imageID
    }
    /*
    func encode(with aCoder: NSCoder){
        aCoder.encode(image, forKey: PropertyKey.image)
        aCoder.encode(question, forKey: PropertyKey.question)
        aCoder.encode(answer, forKey: PropertyKey.answer)
        aCoder.encode(url, forKey: PropertyKey.url)
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        guard let question = aDecoder.decodeObject(forKey: PropertyKey.question) as? String else{
            return nil
        }
        
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        let answer = aDecoder.decodeObject(forKey: PropertyKey.answer)
        let url = aDecoder.decodeObject(forKey: PropertyKey.url)
        
        self.init(image: image, question: question, answer: answer as! String, url: url as! String)
    }*/
}

struct PropertyKey{
    static let question = "question"
    static let image = "image"
    static let answer = "answer"
    static let url = "url"
    static let imageID = "imageID"
}
