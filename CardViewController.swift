//
//  CardViewController.swift
//  khan6210_a3
//
//  Created by Faham Khan on 2018-02-08.
//  Copyright © 2018 wlu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
class CardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MAKE:Attributes
    
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var spotDescription: UILabel!
    @IBOutlet weak var addComment: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var spotTitle: UILabel!
    var commentArray = [String]()
    var c_schools = [ColoredUniversity]()
    var nearbyUniversity:ColoredUniversity?
    
    var card : Card?
    var currentImage: UIImage?
    var ref: DatabaseReference!
    var labelView = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addComment.layer.cornerRadius = 4
        

        addComment.tintColor = nearbyUniversity?.getMainColor()
        addComment.backgroundColor = nearbyUniversity?.getBackColor()
        print("we got the card")
        if let card = card {
            spotTitle.text = card.getQuestion()
            spotTitle.textColor = nearbyUniversity?.getMainColor()
            spotDescription.text   = card.getAnswer()
            spotDescription.textColor = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.0)
            spotImage.image = card.getImage()
            
        }
        
        var cardID = (card?.getUrl())!
        ref = Database.database().reference().child("COMMENTS").child(cardID)
        
        print("The card id is: ",cardID)
        if cardID != nil {
            
            self.ref.queryOrderedByKey().observe(DataEventType.value, with: { (snapshot) in
                // Get user value
                //self.commentArray.removeAll()
                let value = snapshot.value as? NSDictionary
                for comments in (value?.allValues)!{
                    print("The value of each is:",comments)
                    var comment = comments as! String
                    if comment != "Empty post here #12424"{
                        self.labelView = self.labelView + "\n" + comment
                        if(!self.commentArray.contains(comment)){
                            self.commentArray.insert(comment, at:0)
                        }
                        print("Yes we are getting here")
                        print(self.commentArray.count)
                        DispatchQueue.main.async {
                            self.commentsTableView.reloadData()
                        }
                        
                        
                    }
                }
                //print(self.labelView)
                //self.commentsLabel.text = self.commentsLabel.text! + self.labelView
                
                
            }) { (error) in
                print("Errrr is: ",error.localizedDescription)
            }
            let storage = Storage.storage()

            let pathReference = storage.reference(withPath: (card?.getImageID())!)
            print("The cardID is: ", cardID)
            pathReference.getData(maxSize: 3 * 1024 * 1024) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print("We got an error Faham")
                    
                    self.spotImage.image = UIImage(named: "spottedmarker.png")
                    
                } else {
                    // Data for "images/island.jpg" is returned
                    self.spotImage.image = UIImage(data: data!)
                    
                }
            }
            
        }
        
    }
    
    func initWithData(data: ColoredUniversity){ self.nearbyUniversity = data
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Array count is: ")
        return self.commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //creating a cell using the custom class
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentsTableViewCell
        print("We get here")
        //the artist object
        let comment: String
        print("We get here2")
        //getting the artist of selected position
        comment = self.commentArray[indexPath.row]
        print("We get here3")
        //adding values to labels
        cell.commentsLabel.text = comment
        cell.commentsLabel.textColor = nearbyUniversity?.getMainColor()
        print("We get here4")
        //returning cell
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set up the view
    }
    
    
    @IBAction func addCommentWindow(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Comment", message: "Enter Text", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = (alert?.textFields![0])?.text// Force unwrapping because we know it exists.
            
            var date = round(Date().timeIntervalSinceReferenceDate)
            var dateString = String(date)
            self.ref = Database.database().reference()
            dateString = dateString.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            let commentID = ("-L-" + dateString)
            
            //self.ref.child("COMMENTS").child((self.card?.getUrl())!).child(commentID).setValue([textField])
            self.ref.child("COMMENTS").child((self.card?.getUrl())!).updateChildValues(([dateString: textField]))
            
            
            print("Text field: \(self.card?.getUrl()))")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
        }))
        
        
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func randomStringWithLength () -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = 8
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0...len{
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MAKE:ACTION
    
}
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}


