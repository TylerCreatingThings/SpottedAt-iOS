//
//  MapsViewController.swift
//  farkkhan_spottedat
//
//  Created by Tyler Farkas on 2018-03-28.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit
import GoogleMaps


class MapsViewController: UIViewController {

    var schools = [University]()
    var spots = [Card]()
    var nearbySpots = [Card]()
    var markers = [GMSMarker]()
    
    var mapView:GMSMapView?
    @IBOutlet var mapsViewObject: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //schools.append(University)
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapsViewObject.camera = camera
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapsViewObject
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
