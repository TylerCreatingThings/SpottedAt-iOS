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
import Firebase
import FirebaseDatabase
import FirebaseStorage


class AddViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var createSpotButton: UIButton!
    let storage = Storage.storage()
    var ref: DatabaseReference!
    let locationManager = CLLocationManager()
    let picker = UIImagePickerController()
    var latitude:Double?
    var longitude:Double?
    
    
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        createSpotButton.layer.cornerRadius = 4
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        titleText.delegate=self
        descriptionText.delegate=self
        updateSaveButtonState()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    
    @IBAction func createSpot(_ sender: UIButton) {
        ref = Database.database().reference()
        let storageRef = storage.reference()
        let title = titleText.text
        let description = descriptionText.text
        let uuid = UUID().uuidString
        let imageID = UUID().uuidString
        self.ref.child("POSTS").child(uuid).setValue(["id":uuid, "title": title, "image": imageID, "description": description, "latitute": latitude, "longitude": longitude])
        
        let newMetadata = StorageMetadata()
        newMetadata.contentType = "image/jpeg";
        var data = Data()
        data = UIImageJPEGRepresentation(imageView.image!, 0.8)!
        print("The image id is: ", imageID)
        let riversRef = storageRef.child(imageID)
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(data as Data, metadata: newMetadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            print("Oh my it worked!")
            let downloadURL = metadata.downloadURL
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        createSpotButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = titleText.text ?? ""
        let text2 = descriptionText.text ?? ""
        
        //if(questionmarkName != enterPicture.backgroundImage(for: .normal)){
        //    checkPic = true;
        // }
        
        createSpotButton.isEnabled = (!text.isEmpty && !text2.isEmpty)
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



