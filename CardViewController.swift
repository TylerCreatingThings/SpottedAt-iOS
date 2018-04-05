//
//  CardViewController.swift
//  khan6210_a3
//
//  Created by Faham Khan on 2018-02-08.
//  Copyright © 2018 wlu. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    //MAKE:Attributes
    
   
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var spotDescription: UILabel!
    
    var card : Card?
    var currentImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("we got the card")
        if let card = card {
            navigationItem.title = card.getQuestion()
            spotDescription.text   = card.getAnswer()
            spotImage.image = card.getImage()
        }
        
        

    }
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set up the view
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MAKE:ACTION
    
}


