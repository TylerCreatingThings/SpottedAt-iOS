//
//  Coloreduniversity.swift
//  farkkhan_spottedat
//
//  Created by Khushi Dahiya on 2018-04-06.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit

class ColoredUniversity: University {
    
    var back_color:UIColor?
    var main_color:UIColor?
    var comp_color:UIColor?

    init(name: String, latitude: Double, longitude: Double, main_color: UIColor, back_color: UIColor, comp_color: UIColor){
        super.init(name: name, latitude: latitude, longitude: longitude)
        self.back_color = back_color
        self.main_color = main_color
        self.comp_color = comp_color
    }
    
    func getMainColor()->UIColor{
        return main_color!
    }
    
    func getBackColor()->UIColor{
        return back_color!
    }
    
    func getCompositeColor()->UIColor{
        return comp_color!
    }
}
