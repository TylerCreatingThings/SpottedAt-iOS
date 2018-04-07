//
//  University.swift
//  farkkhan_spottedat
//
//  Created by Khushi Dahiya on 2018-04-05.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit

class University: NSObject {
    let name:String?
    let latitude:Double?
    let longitude:Double?

    
    init(name: String, latitude: Double, longitude: Double){
       self.name = name
       self.latitude = latitude
       self.longitude = longitude
    }
    
    func getName()->String{
        return name!
    }
    
    func getLatitude()->Double{
        return latitude!
    }
    
    func getLongitude()->Double{
        return longitude!
    }
}
