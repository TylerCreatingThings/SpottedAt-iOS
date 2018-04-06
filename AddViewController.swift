//
//  MapsViewController.swift
//  farkkhan_spottedat
//
//  Created by Tyler Farkas on 2018-03-28.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit
import os.log
import MapKit
import CoreLocation


class AddViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let picker = UIImagePickerController()
    var latitude:Double?
    var longitude:Double?
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        picker.delegate = self
        
        //take delegates of textfields
        addTitleText.delegate = self
        addDescriptionText.delegate = self
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
    
    @IBOutlet weak var addTitleText: UITextField!
    @IBOutlet weak var addDescriptionText: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addTitleText.resignFirstResponder()
        self.addDescriptionText.resignFirstResponder()
        return true
    }
    
    @IBAction func uploadPicture(_ sender: Any) {
        //get curr location
        //
        
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    
    
    
    @IBAction func pickUserImage(_ sender: Any) {
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}



