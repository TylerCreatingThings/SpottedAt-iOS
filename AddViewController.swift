//
//  MapsViewController.swift
//  farkkhan_spottedat
//
//  Created by Tyler Farkas on 2018-03-28.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit
import os.log



class AddViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBOutlet weak var addTitleText: UITextField!
    @IBOutlet weak var addDescriptionText: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addTitleText.resignFirstResponder()
        self.addDescriptionText.resignFirstResponder()
        return true
    }
    
    
    @IBOutlet weak var addImageView: UIButton!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        // do something interesting here!
        addImageView.setImage(newImage, for:  .normal)
        addImageView.sizeToFit()
        dismiss(animated: true)
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



