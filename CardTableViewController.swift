//
//  CardTableViewController.swift
//  fark3230_a4
//
//  Created by Tyler Farkas on 2018-03-05.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Foundation
import Darwin
import MapKit
import CoreLocation

class CardTableViewController: UITableViewController, URLSessionTaskDelegate, XMLParserDelegate, CLLocationManagerDelegate  {
    var ref: DatabaseReference!
    var dataStore = NSData();
    var currentElement = ""
    var currentLinkElement = ""
    var processingElement = false
    var processingLinkElement = false
    let ELEMENT_NAME = "description"
    let LINK_NAME = "link"
    var deck = Deck()
    var schools = [University]()
    var latitude:Double?
    var longitude:Double?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ref = Database.database().reference()
        
        self.ref.child("Users").setValue(["username": "FahamKhan Lets go"])
        ref.child("POSTS").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //var tests = value?.allValues[0] as? NSDictionary
            //print("username is:",tests!["description"])
            var currentImage: UIImage?
            currentImage = UIImage(named:"fahamk.png");
            for name in (value?.allValues)!{
                var dictionary = name as? NSDictionary
                var name = (dictionary!["title"])!
                
                print("Value is: ", (dictionary!["description"])!)
                self.deck.addCard(newQuestion: name as! String, newAnswer: "test", newImage: currentImage!, newUrl: "test")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("UNIVERSITIES").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //var tests = value?.allValues[0] as? NSDictionary
            //print("username is:",tests!["description"])
            
            for name in (value)!{
                
                print(name.key)
                
                var dictionary = name.value as? NSDictionary
                var lat = (dictionary!["latitude"])!
                var long = (dictionary!["longitude"])!
                self.schools.append(University(name: name.key as! String, latitude: lat as! Double, longitude: long as! Double))
            }
            
            /*
            Object value = dataSnapshot.getValue();
            String innerValue = value.toString();
            int location = innerValue.lastIndexOf("}");
            String[] vals = value.toString().substring(innerValue.indexOf("uni-"), location).split("uni-");
            //Hearst={latitude=49.7075, longitude=-83.66544},
            for (String values : vals) {
                if(!values.equals("")) {
                    String name = values.substring(0, values.indexOf("="));
                    String latitude = values.substring(values.indexOf("latitude=")+9, values.indexOf(","));
                    String longitude = values.substring(values.indexOf("longitude=")+10, values.indexOf("}"));
                    University uni = new University(name, Double.parseDouble(latitude), Double.parseDouble(longitude));
                    mUniversityValues.add(uni);
                }
            }
            */
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func readDataBase(curElement: NSString, curLinkElement: NSString){
            //let imageQueue = DispatchQueue(label: "Image Queue", attributes: .concurrent)
        
            DispatchQueue.main.async {
                // get image from the Web
                //image = UIImage(data: imageData! as Data)
                let deck:Deck = SharingDeck.sharedDeck.getDeck()!
                //deck.addCard(newQuestion: theTitle! as String , newAnswer: theDescription! as String, newImage: image!, newUrl: theLink! as String)
                SharingDeck.sharedDeck.setDeck(newDeck: deck)
                self.tableView.reloadData()
            }
        }
        
    
    
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "CardDetailView" {
    //get the index of the row selected in the table
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!;
    //segue to the details screen
        let detailVC = segue.destination as! DetailViewController;
    //set the selected rss item in the details view
        detailVC.initWithData(data: indexPath.row)
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = locValue.latitude
        longitude = locValue.longitude
    }

    // MARK: - Table view data source
    /*        University selected = new University("Laurier",43.4724,-80.5263);
     try {
     for(University uni : mUniversityValues){
     Log.d("main","Latuide is"+mLatitude+" "+mLongitude);
     double distance = calculateDistance(mLatitude,mLongitude,uni.getLatitude(),uni.getLongitude());
     if(min > distance){
     min = distance;
     selected = uni;
     }
     }
     }
     catch (NullPointerException e){
     e.printStackTrace();
     return null;
     }
     return selected.getName();*/
    func getNeartestUniversity()->String{
        
        var selected:University?
        var min:Double = Double.greatestFiniteMagnitude
        for uni in self.schools {
            let distance:Double = calculateDistance(lat1: self.latitude!, lon1: self.longitude!, lat2: uni.getLatitude(), lon2: uni.getLongitude())
            if(min > distance){
                min = distance
                selected = uni
            }
            
        }
        return (selected?.getName())!
        
    }

    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double)->Double{
        let earthRadius:Double = 6371
        let rLat1 = lat1 * .pi / 180
        let rLat2 = lat2 * .pi / 180
        let latDiff = (lat2-lat1) * .pi / 180
        let longDiff = (lon2-lon1) * .pi / 180
        let a = sin(latDiff/2) * sin(latDiff/2) + cos(rLat1) + cos(rLat2) + sin(longDiff/2) * sin(longDiff/2)
        let c = 2 * atan2(sqrt(a),sqrt(1-a))
        let distance = earthRadius * c
        return distance
    }
    
    /* public void getNearbySpots(){
     int min = 10;
     Log.d("WSM","GetNearbySpots"+Integer.toString(mSpots.size()));
     
     try {
     for(Card curCard : mSpots){
     if((abs(mLatitude-curCard.getLatitude()))<TEN_KILOMETERS || (abs(mLongitude-curCard.getLongitude()))<TEN_KILOMETERS) {
     double distance = calculateDistance(mLatitude, mLongitude, curCard.getLatitude(), curCard.getLongitude());
     if (min > distance) {
     Log.d("WSM","Got nearby spots");
     mNearbySpots.add(curCard);
     }
     }
     }
     }
     catch (NullPointerException e){
     e.printStackTrace();
     }
     if(mMap!=null) {
     placeMarkers();
     }
     }
*/
    func getNearbySpots(){
        var min = UInt16.max
        
    }
    
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
        cell.photoImageView.image = card.getImage()
        
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
