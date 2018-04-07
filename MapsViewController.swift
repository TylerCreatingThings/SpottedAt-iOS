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
import Foundation
import MapKit
import CoreLocation

@available(iOS 11.0, *)
class MapsViewController: UIViewController,CLLocationManagerDelegate, XMLParserDelegate,GMSMapViewDelegate {
    
    
    let TEN_KILOMETERS = 0.09009009009
    var custom_kilometers:Double = 2
    var schools = [University]()
    var spots = [Card]()
    var nearbySpots = [Card]()
    var markers = [GMSMarker]()
    var latitude:Double = 43.4723530
    var longitude:Double = -80.5263400
    let locationManager = CLLocationManager()
    var ref: DatabaseReference!
    var dataStore = NSData();
    var deck = Deck()
    var cameraBound = GMSCoordinateBounds()
    let main_color = UIColor(named: "white")
    let back_color = UIColor(named: "white")
    let comp_color = UIColor(named: "white")
    var c_schools = [ColoredUniversity]()

    
    //colors:
    let red = UIColor(red:0.49, green:0.00, blue:0.00, alpha:1.0)
    let green = UIColor(red:0.00, green:0.49, blue:0.00, alpha:1.0)
    let blue = UIColor(red:0.00, green:0.00, blue:0.49, alpha:1.0)
    let yellow = UIColor(red:1.00, green:1.00, blue:0.00, alpha:1.0)
    let black = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
    let white = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    let grey = UIColor(red:0.50, green:0.50, blue:0.50, alpha:1.0)
    let purple = UIColor(red:0.50, green:0.00, blue:0.50, alpha:1.0)
    let orange = UIColor(red:1.00, green:0.65, blue:0.00, alpha:1.0)


    
    var mapView:GMSMapView?
    @IBOutlet var mapsViewObject: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        custom_kilometers = calculateKilometerDistance(kilometers: 5)
        
     
        
        
        /*
         // Creates a marker in the center of the map.
         let marker = GMSMarker()
         marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
         marker.title = "Sydney"
         marker.snippet = "Australia"
         marker.map = mapsViewObject
         */
        
        mapsViewObject.settings.myLocationButton = true
        startReceivingLocationChanges()
        
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
                let dictionary = name as? NSDictionary
                let name = (dictionary!["title"])!
                let lat = (dictionary!["latitude"])!
                let long = (dictionary!["longitude"])!
             
                
                
                print("Value is: ", (dictionary!["description"])!)
                self.spots.append(Card(image: currentImage!, question: name as! String, answer: "test", url: "test", latitude: lat as! Double, longitude: long as! Double)!)
                
                
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
            //var tests = value?.allValues[0] as? NSDictionary
            //print("username is:",tests!["description"])
            
            for name in (value)!{
                
                print(name.key)
                
                var dictionary = name.value as? NSDictionary
                var lat = (dictionary!["latitude"])!
                var long = (dictionary!["longitude"])!
                let main = (dictionary!["color_back"])!
                let back = (dictionary!["color_main"])!
                let comp = (dictionary!["color_composite"])!

                
                if(comp as! String == "blank"){
                    self.c_schools.append(ColoredUniversity(name: name.key as! String, latitude: lat as! Double, longitude: long as! Double,main_color: UIColor(named: main as! String)!, back_color: UIColor(named: back as! String)!, comp_color: UIColor(named: "black")! ))
                }
                else{
                        self.c_schools.append(ColoredUniversity(name: name.key as! String, latitude: lat as! Double, longitude: long as! Double,main_color: UIColor(named: main as! String)!, back_color: UIColor(named: back as! String)!, comp_color: UIColor(named: comp as! String)! ))
                }
               
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        //schools.append(University)
        
       
        
        // Do any additional setup after loading the view.
    }
   
    /*override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 6.0)
        mapsViewObject.camera = camera
        
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getColor(color: String)->UIColor{
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print ("MarkerTapped Locations: \(marker.position.latitude), \(marker.position.longitude)")
        
        for place in (nearbySpots) {
            if(marker.position.latitude == place.getLatitude() && marker.position.latitude == place.getLongitude()){
                let vc = CardViewController() //your view controller
                vc.card = place
                
                self.present(vc, animated: true, completion: nil)
            }
        }
        return true
    }
    
    func getNeartestUniversity()->ColoredUniversity{
        
        var selected:ColoredUniversity?
        var min:Double = Double.greatestFiniteMagnitude
        for uni in self.c_schools {
            let distance:Double = calculateDistance(lat1: self.latitude, lon1: self.longitude, lat2: uni.getLatitude(), lon2: uni.getLongitude())
            if(min > distance){
                min = distance
                selected = uni
            }
            
        }
        return selected!
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
       // latitude = locValue.latitude
       // longitude = locValue.longitude

    }
    
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
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
    @IBOutlet weak var centerButton: UIBarButtonItem!
    
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
                marker.icon = UIImage(named: "spottedmarker-mini")
                markers.append(marker)
                cameraBound.includingCoordinate(marker.position)
                print(spot.getQuestion())
            }
            
            
            let update = GMSCameraUpdate.fit(cameraBound, with: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
            mapsViewObject.moveCamera(update)
            mapsViewObject.animate(toZoom: 16)
        
        var nearUni = getNeartestUniversity()
        
        universityTitle.text = "Spotted @ " + nearUni.getName()
        universityTitle.textColor = nearUni.main_color
        listButton.tintColor = nearUni.back_color
        centerButton.tintColor = nearUni.back_color
    }
    func updateCameraToBounds(){
            let update = GMSCameraUpdate.fit(cameraBound, with: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
            mapsViewObject.moveCamera(update)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
