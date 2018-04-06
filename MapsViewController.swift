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

class MapsViewController: UIViewController,CLLocationManagerDelegate, XMLParserDelegate {

    
    let TEN_KILOMETERS = 0.09009009009
    var schools = [University]()
    var spots = [Card]()
    var nearbySpots = [Card]()
    var markers = [GMSMarker]()
    var latitude:Double?
    var longitude:Double?
    let locationManager = CLLocationManager()
    var ref: DatabaseReference!
    var dataStore = NSData();
    var deck = Deck()
    
    var mapView:GMSMapView?
    @IBOutlet var mapsViewObject: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapsViewObject.camera = camera
        
        /*
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapsViewObject
        */
        
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
                var lat = (dictionary!["latitude"])! as! Double
                var long = (dictionary!["longitude"])! as! Double

                
                
                print("Value is: ", (dictionary!["description"])!)
                self.spots.append(Card(image: currentImage!, question: name as! String, answer: "test", url: "test", latitude: lat, longitude: long)!)
                
                
            }
            if(self.mapsViewObject != nil){
                self.getNearbySpots()
                self.placeMarkers()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //schools.append(University)

        
        // Do any additional setup after loading the view.
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
        //var min = 10
        
        for spot in spots {
            if((abs(self.latitude! - spot.getLatitude()))<TEN_KILOMETERS || (abs(self.longitude! - spot.getLongitude()))<TEN_KILOMETERS){
                let distance = calculateDistance(lat1: self.latitude!, lon1: self.longitude!, lat2: spot.getLatitude(), lon2: spot.getLongitude())
                nearbySpots.append(spot)
            }
        }
        
    }
    
    func calculateDistance(kilometers: Int)->Double{
        let one_degree = 111
        let distance:Double = Double(kilometers/one_degree)
        return distance
    }
    /*public void placeMarkers(){
     Log.d("WSM","placeMarkers"+Integer.toString(mSpots.size()));
     //Set Camera to current location
     Log.d("main","OK SO THIS IS THE LOCATION:"+mLongitude+" "+mLatitude);
     LatLng curLocation = new LatLng(mLatitude, mLongitude);
     if(permReady==false){
     Log.d("test","Not this time");
     permReady=true;
     }
     else {
     mMap.moveCamera(CameraUpdateFactory.newLatLng(curLocation));
     mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLatitude, mLongitude), 12.0f));
     
     }
     Log.d("WSM","Got here" + Integer.toString(mNearbySpots.size()));
     
     
     
     for(Card curCard : mNearbySpots){
     Log.d("WSM","Placing markers");
     LatLng curSpot = new LatLng(curCard.getLatitude(), curCard.getLongitude());
     mMarkers.add(mMap.addMarker(new MarkerOptions().position(curSpot).title(curCard.getTitle()).icon(BitmapDescriptorFactory.fromResource(R.drawable.spottedmarker))));
     }
     
     if(mNearbySpots.size()>0) {
     LatLngBounds.Builder builder = new LatLngBounds.Builder();
     LatLng curPoint = new LatLng(mLatitude,mLongitude);
     builder.include(curPoint);
     for (Marker marker : mMarkers) {
     builder.include(marker.getPosition());
     }
     LatLngBounds bounds = builder.build();
     int padding = 100; // offset from edges of the map in pixels
     cu = CameraUpdateFactory.newLatLngBounds(bounds, padding);
     if(mMap!=null) {
     mMap.setOnMapLoadedCallback(new GoogleMap.OnMapLoadedCallback() {
     @Override
     public void onMapLoaded() {
     mMap.animateCamera(cu);                    }
     });
     
     
     }
     }
     }*/
    func placeMarkers(){
        if(nearbySpots.count > 0){
            var cameraBound = GMSCoordinateBounds()
            let curPoint = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            cameraBound.includingCoordinate(curPoint)
            for spot in (nearbySpots) {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: spot.getLatitude(), longitude: spot.getLongitude())
                marker.title = spot.getQuestion()
                marker.snippet = spot.getQuestion()
                marker.map = mapsViewObject
                markers.append(marker)
                cameraBound.includingCoordinate(marker.position)
            }
            let camera = mapsViewObject.camera(for: cameraBound, insets: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
            mapsViewObject.camera = camera!
        }
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
