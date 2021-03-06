//
//  CardTableViewController.swift
//  fark3230_a4
//
//  Created by Tyler Farkas on 2018-03-05.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import os.log
import Darwin
import MapKit
import Foundation
import CoreLocation


@available(iOS 11.0, *)
class CardTableViewController: UITableViewController, URLSessionTaskDelegate, XMLParserDelegate, CLLocationManagerDelegate  {
    
    var ref = Database.database().reference()
    var dataStore = NSData();
    let urlPath: String = "http://rss.cbc.ca/lineup/topstories.xml"
    var currentElement = ""
    var currentLinkElement = ""
    var processingElement = false
    var processingLinkElement = false
    let ELEMENT_NAME = "description"
    let LINK_NAME = "link"
    var deck = Deck()
    var card:Card?
    let storage = Storage.storage()
    var nearbyUniversity:ColoredUniversity?
    var latitude:Double?
    var longitude:Double?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if(card != nil){
            //self.navigationController?.pushViewController(nextViewController, animated: true)
            self.performSegue(withIdentifier: "ShowDetailDiff", sender: nil)
        }
        
        self.navigationItem.title = "Spots"
        self.presentingViewController?.title = "Spots"
        addButton.tintColor = nearbyUniversity?.getMainColor()
        mapButton.tintColor = nearbyUniversity?.getMainColor()
        refreshButton.tintColor = nearbyUniversity?.getMainColor()
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        getData()
        
        //ref = Database.database().reference().child("COMMENTS").child(cardID)
        
        
        //if cardID != nil {
        
        //    self.ref.queryOrderedByKey().observe(DataEventType.value, with: { (snapshot) in
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
    
   
    @IBAction func refreshValues(_ sender: UIBarButtonItem) {
        getData()
    }
    
    
    
    func getData(){
        refreshButton.isEnabled=false
        ref.removeAllObservers()
        
        ref.child("POSTS").queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //var tests = value?.allValues[0] as? NSDictionary
            //print("username is:",tests!["description"])
            
            var currentImage: UIImage?
            currentImage = UIImage(named:"fahamk.png");
            var counter = 0
            for name in (value?.allValues)!{
                let dictionary = name as? NSDictionary
                let name = (dictionary!["title"])!
                let imageName = (dictionary!["image"])! as! String
                let longitude=(dictionary!["longitude"])! as! Double
                let latitude = (dictionary!["latitude"])! as! Double
                let date = (dictionary!["date"])! as! Int
                let id = (value?.allKeys[counter])! as! String
                var description = (dictionary!["description"])! as! String
                
                if(description == ""){
                    description = " "
                }
                let pathReference = self.storage.reference(withPath: imageName)
                DispatchQueue.main.async {
                    pathReference.getData(maxSize: 3 * 1024 * 1024) { data, error in
                        if let error = error {
                            // Uh-oh, an error occurred!
                            //print("We got an error Faham")
                            currentImage = UIImage(named: "spottedmarker.png")
                            print("description: ", description)
                            
                            self.deck.addCard(newQuestion: name as! String, newAnswer: description, newImage: currentImage!, newUrl: id, latitude: latitude, longitude: longitude, imageID: imageName as! String)
                            self.tableView.reloadData()
                            
                        } else {
                            // Data for "images/island.jpg" is returned
                            currentImage = UIImage(data: data!)
                            print("description: ", description)
                            self.deck.addCard(newQuestion: name as! String, newAnswer: description, newImage: currentImage!, newUrl: id, latitude: latitude, longitude: longitude, imageID: imageName as! String)
                            
                            self.tableView.reloadData()
                            
                        }
                    }
                }
                
                //print("Value is: ", (dictionary!["description"])!)
                counter = counter+1
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        refreshButton.isEnabled=true
    }
    
    
    func initWithData(data: ColoredUniversity){ self.nearbyUniversity = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        super.prepare(for: segue, sender: sender)
        
        if(segue.identifier == "addSpot"){
            let addViewController = segue.destination as? AddViewController
            addViewController?.initWithData(data: self.nearbyUniversity!)
        }
        else if(segue.identifier == "mapShow"){
            let mapViewController = segue.destination as? MapsViewController
            mapViewController?.initWithData(data: self.nearbyUniversity!)
        }
        
        
        switch(segue.identifier ?? "") {
        case "ShowDetail":
            guard let CardViewController = segue.destination as? CardViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCardCell = sender as? CardTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedCardCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedCard = deck.getElementAtIndex(index: indexPath.row)
            CardViewController.card = selectedCard
            print("Here again too")
            
        case "mapShow":
            guard let mapViewController = segue.destination as? MapsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
        case "addSpot":
            guard let addViewController = segue.destination as? AddViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
        
        
    }
    
    
    
    
    
    
    
    @IBAction func unwindToDeckList( sender: UIStoryboardSegue) {
        print("do you atleast get here?")
        
        /* if let sourceViewController = sender.source as? AddViewController, let addCard = sourceViewController.addCard {
         let deck:Deck = SharingDeck.sharedDeck.getDeck()!
         // Add a new meal.
         print("do you get here?")
         let newIndexPath = IndexPath(row: deck.getLength(), section: 0)
         
         deck.addCard(newQuestion: addCard.getQuestion(), newAnswer: addCard.getAnswer(), newImage: addCard.getImage())
         tableView.insertRows(at: [newIndexPath], with: .automatic)
         }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //return length of list here.
        return self.deck.getLength()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "CardTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CardTableViewCell else {
            fatalError("Dequeued cell is not an instance of CardTableViewCell")
        }
        
        let card = self.deck.getElementAtIndex(index: indexPath.row)
        
        cell.nameLabel.text = card.getQuestion()
        cell.nameLabel.textColor = nearbyUniversity?.getMainColor()
        cell.photoImageView.image = card.getImage()
        cell.descriptionLabel.text = card.getAnswer()
        cell.descriptionLabel.textColor = nearbyUniversity?.getBackColor()
        cell.mainBackground.layer.shadowColor = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.0).cgColor
        cell.mainBackground.layer.shadowColor = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.0).cgColor
        cell.descriptionLabel.layer.borderColor = UIColor.purple.cgColor
        cell.mainBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.mainBackground.layer.shadowRadius = 4.0
        cell.mainBackground.layer.shadowOpacity = 1.0
        cell.mainBackground.layer.masksToBounds = false
        cell.mainBackground.layer.cornerRadius = 8
        
        cell.mainBackground.layer.shadowPath = UIBezierPath(roundedRect: cell.mainBackground.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            tableView.beginUpdates()
            self.deck.setCard(index: indexPath.row)
            self.deck.deleteCurrentCard()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            
        }
    }
    
    
    
}
