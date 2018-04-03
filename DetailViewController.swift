//
//  DetailViewController.swift
//  fark3230_a4
//
//  Created by Tyler Farkas on 2018-03-05.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {


    
    var curCard:Card?
    override func viewDidLoad() {
        super.viewDidLoad()
        SharingDeck.sharedDeck.loadDeck()
        // Do any additional setup after loading the view.
        
        let theCard:Card = (SharingDeck.sharedDeck.getDeck()?.card())!
        
        transitionPicture.image = theCard.getImage()
        transitionQuestion.text = theCard.getAnswer()
        transitionQuestion.sizeToFit()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationItem.title = theCard.getQuestion()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var transitionQuestion: UILabel!
    @IBOutlet weak var transitionPicture: UIImageView!
    func initWithData(data: Int){
        SharingDeck.sharedDeck.getDeck()?.setCard(index: data)
        curCard = (SharingDeck.sharedDeck.getDeck()?.card())!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddViewController" {
            //get the index of the row selected in the table
            //segue to the details screen
            let detailVC = segue.destination as! AddViewController;
            //set the selected rss item in the details view
            detailVC.initWithData(data: curCard!.getUrl())
        }
    }
    
    @IBOutlet weak var questionPicture: UIImageView!
    @IBOutlet weak var questionText: UILabel!
    @IBAction func showQuestion(_ sender: Any) {

            let curDeck:Deck = SharingDeck.sharedDeck.getDeck()!
            if(curDeck.isEmpty()){
                questionText.text = "Please add a question using the Add Card tab"
                questionPicture.image = UIImage(named: "question")
                questionText.sizeToFit()
            }
            else{
                curDeck.next()
                let curCard:Card = curDeck.card()
                questionText.text = curCard.getQuestion()
                questionPicture.image = curCard.getImage()
                questionText.sizeToFit()
            }
    }
    

    

}
