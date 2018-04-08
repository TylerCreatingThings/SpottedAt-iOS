//
//  MapsViewController.swift
//  farkkhan_spottedat
//
//  Created by Tyler Farkas on 2018-03-28.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
import FirebaseStorage
import Foundation
import MapKit
import CoreLocation
import Darwin
import CoreMotion

@available(iOS 11.0, *)
class MapsViewController: UIViewController,CLLocationManagerDelegate, XMLParserDelegate,GMSMapViewDelegate {
    
    
    let TEN_KILOMETERS = 0.09009009009
    var custom_kilometers:Double = 2
    var spots = [Card]()
    var nearbySpots = [Card]()
    var markers = [GMSMarker]()
    var latitude:Double = 43.5321
    var longitude:Double = -80.2269
    let locationManager = CLLocationManager()
    var ref: DatabaseReference!
    var dataStore = NSData();
    var deck = Deck()
    var cameraBound = GMSCoordinateBounds()
    let main_color = UIColor(named: "white")
    let back_color = UIColor(named: "white")
    let comp_color = UIColor(named: "white")
    var c_schools = [ColoredUniversity]()
    var card:Card?

    
    //colors:
    let red = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
    let green = UIColor(red:0.00, green:1.00, blue:0.00, alpha:1.0)
    let blue = UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0)
    let yellow = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.0)
    let black = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
    let white = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    let grey = UIColor(red:0.50, green:0.50, blue:0.50, alpha:1.0)
    let purple = UIColor(red:0.50, green:0.00, blue:0.50, alpha:1.0)
    let orange = UIColor(red:1.00, green:0.65, blue:0.00, alpha:1.0)
    
    var nearestUni:ColoredUniversity?

    
    var mapView:GMSMapView?
    @IBOutlet var mapsViewObject: GMSMapView!
    
    
    @IBOutlet weak var mapToolBar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage()

        custom_kilometers = calculateKilometerDistance(kilometers: 5)
        mapsViewObject.delegate = self
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        ref = Database.database().reference()
        
        ref.child("POSTS").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //var tests = value?.allValues[0] as? NSDictionary
            //print("username is:",tests!["description"])
            var currentImage: UIImage?
            currentImage = UIImage(named:"spottedmarker");
            var counter = 0
            for name in (value?.allValues)!{
                let dictionary = name as? NSDictionary
                let name = (dictionary!["title"])!
                var description = (dictionary!["description"])! as! String
                let lat = (dictionary!["latitude"])!
                let long = (dictionary!["longitude"])!
                let date = (dictionary!["date"])!
                let imageName = (dictionary!["image"])! as! String
                let id = (value?.allKeys[counter])! as! String
                
                
                if(description == ""){
                    description = " "
                }
                
                
                print("Value is: ", (dictionary!["description"])!)
                self.spots.append(Card(image: currentImage!, question: name as! String, answer: description, url: id, latitude: lat as! Double, longitude: long as! Double, imageID: imageName as! String)!)
                
                counter = counter + 1
            }
            
            if(self.mapsViewObject != nil){
                self.getNearbySpots()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        ref.child("UNIVERSITIES").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            for name in (value)!{
                
                print(name.key)
                
                var dictionary = name.value as? NSDictionary
                var lat = (dictionary!["latitude"])!
                var long = (dictionary!["longitude"])!
                let main = (dictionary!["color_main"])!
                let back = (dictionary!["color_back"])!
                let comp = (dictionary!["color_composite"])!

                self.c_schools.append(ColoredUniversity(name: name.key as! String, latitude: lat as! Double, longitude: long as! Double,main_color: self.getColor(color: main as! String), back_color: self.getColor(color: back as! String), comp_color: self.getColor(color: comp as! String) ))
               
                
            }
            self.nearestUni = self.getNeartestUniversity()
        }) { (error) in
            print(error.localizedDescription)
        }
        
       
        
        // Do any additional setup after loading the view.
    }
   
    func initWithData(data: ColoredUniversity){ self.nearestUni = data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getColor(color: String)->UIColor{
        switch color
        {
            case "red" :
                return red
            case "blue" :
                return blue
            case "purple" :
                return purple
            case "orange" :
                return orange
            case "yellow" :
                return yellow
            case "black" :
                return black
            case "white" :
                return white
            default :
                return green
        }
    }
    
    func getMarkerColor(color: UIColor)->String{
        switch color
        {
        case red :
            return "spottedmarker-mini-red"
        case blue :
            return "spottedmarker-mini-blue"
        case purple :
            return "spottedmarker-mini-purple"
        case orange :
            return "spottedmarker-mini-orange"
        case yellow :
            return "spottedmarker-mini-yellow"
        case black :
            return "spottedmarker-mini-black"
        case white :
            return "spottedmarker-mini-white"
        default :
            return "spottedmarker-mini"
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print ("MarkerTapped Locations: \(marker.position.latitude), \(marker.position.longitude)")
        
        for place in (nearbySpots) {
            print(place.getLatitude(),place.getLongitude())
            
            let x = GMSMarker(position: CLLocationCoordinate2D(latitude: place.getLatitude(), longitude: place.getLongitude()))
            if(marker.position.latitude == x.position.latitude && marker.position.latitude == x.position.latitude){
                let vc = CardViewController() //your view controller
                card = place
                self.performSegue(withIdentifier: "ShowEventDetails", sender: self)
                break
            }
            
        }
        return true
    }
    
    func getNeartestUniversity()->ColoredUniversity{
        
        var selected = ColoredUniversity(name: "", latitude: 0, longitude: 0, main_color: red, back_color: red, comp_color: red)
        var min:Double = Double.greatestFiniteMagnitude
        for uni in self.c_schools {
            let distance:Double = calculateDistance(lat1: self.latitude, lon1: self.longitude, lat2: uni.getLatitude(), lon2: uni.getLongitude())

            if(min > distance){
                min = distance
                selected = uni
            }
            
        }
        return selected
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //latitude = locValue.latitude
        //longitude = locValue.longitude

    }
    
    
    
    func getNearbySpots(){
        //var min = 10
        
        for spot in spots {
            
            if((abs(self.latitude - spot.getLatitude()))<custom_kilometers || (abs(self.longitude - spot.getLongitude()))<custom_kilometers){
                let distance = calculateDistance(lat1: self.latitude, lon1: self.longitude, lat2: spot.getLatitude(), lon2: spot.getLongitude())
                nearbySpots.append(spot)
            }
        }
        placeMarkers()

        
    }
    
    
    func calculateKilometerDistance(kilometers: Double)->Double{
        let one_degree:Double = 111
        let distance:Double = kilometers/one_degree
        return distance
    }
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var centerButton: UIButton!
    
    @IBOutlet weak var universityTitle: UILabel!
    func placeMarkers(){

        
            let curPoint = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            cameraBound.includingCoordinate(curPoint)
            for spot in (nearbySpots) {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: spot.getLatitude(), longitude: spot.getLongitude())
                marker.title = spot.getQuestion()
                marker.snippet = spot.getQuestion()
                marker.map = mapsViewObject
                marker.icon = UIImage(named: getMarkerColor(color: (nearestUni?.getMainColor())!))
                markers.append(marker)
                cameraBound.includingCoordinate(marker.position)
                print(spot.getQuestion())
            }
            
            
            let update = GMSCameraUpdate.fit(cameraBound, with: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
            mapsViewObject.moveCamera(update)
            mapsViewObject.animate(toZoom: 16)
        
 
        
        universityTitle.text = "Spotted @ " + nearestUni!.getName()
        universityTitle.textColor = nearestUni!.getMainColor()
        universityTitle.backgroundColor = nearestUni?.getBackColor()
        universityTitle.tintColor = nearestUni?.getBackColor()
        mapToolBar.tintColor = nearestUni?.getMainColor()
        mapToolBar.backgroundColor = nearestUni?.getMainColor()
        mapToolBar.barTintColor = nearestUni?.getMainColor()
        listButton.tintColor = nearestUni!.getBackColor()
        centerButton.tintColor = nearestUni!.getBackColor()
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        mapsViewObject.camera = camera
    }
    

    
    @IBAction func centerMap(_ sender: Any) {
                let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        mapsViewObject.moveCamera(GMSCameraUpdate.setCamera(camera))
        
    }
    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double)->Double{
        let earthRadius:Double = 6371
        let rLat1 = lat1 * .pi / 180
        let rLat2 = lat2 * .pi / 180
        let rLon1 = lon1 * .pi / 180
        let rLon2 = lon2 * .pi / 180
        
        let latDiff = (lat2 - lat1) * .pi / 180
        let longDiff = (lon2 - lon1) * .pi / 180
        let a = sin(latDiff/2) * sin(latDiff/2) + cos(rLat1) * cos(rLat2) * sin(longDiff/2) * sin(longDiff/2)
        var c = 2.0 * (atan2(sqrt(a),sqrt(abs(1-a))))
        
        let distance = earthRadius * c
        return distance
    }
    
    
     // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        super.prepare(for: segue, sender: sender)
        if(segue.identifier == "showList"){
            let dest = segue.destination as! UINavigationController
            let destVC = dest.viewControllers.first as! CardTableViewController
            destVC.initWithData(data: self.nearestUni!)
            
        }
        else if(segue.identifier == "ShowEventDetails"){
            guard let CardViewController = segue.destination as? CardViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            print("The id of card is: ",self.card?.getUrl())
            CardViewController.card = self.card
            CardViewController.initWithData(data: nearestUni!)
        }
    }
    
}
