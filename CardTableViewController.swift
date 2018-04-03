//
//  CardTableViewController.swift
//  fark3230_a4
//
//  Created by Tyler Farkas on 2018-03-05.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit

class CardTableViewController: UITableViewController, URLSessionTaskDelegate, XMLParserDelegate  {

    var dataStore = NSData();
    let urlPath: String = "http://rss.cbc.ca/lineup/topstories.xml"
    var currentElement = ""
    var currentLinkElement = ""
    var processingElement = false
    var processingLinkElement = false
    let ELEMENT_NAME = "description"
    let LINK_NAME = "link"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "CBC News Feed"
        self.presentingViewController?.title = "CBC News Feed"
        SharingDeck.sharedDeck.loadDeck()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if(SharingDeck.sharedDeck.getDeck() == nil){
            let curDeck = Deck()
            SharingDeck.sharedDeck.setDeck(newDeck: curDeck)
        
        let url: NSURL = NSURL(string: urlPath)!
        let request: URLRequest = URLRequest(url: url as URL)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request, completionHandler:{ (data, response, error) in
            self.dataStore = data! as NSData
            
            _ = NSString(data: self.dataStore as Data, encoding: String.Encoding.utf8.rawValue)
            DispatchQueue.main.async { // must handle UI methods in the main thread
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            self.parseXML()
        })
        
        task.resume()
        }
    }
    
    func readWebElements(curElement: NSString, curLinkElement: NSString){
        
        let check = curElement as String
        if check.range(of:"PERSONAL") != nil {
            print("exists")
        }
        else{
        let theScanner = Scanner(string: curElement as String)
        
        //what info do I need ?
        
        //title and img endings are next '
        let TITLE = "title=\'"

        let quoteSet =  NSCharacterSet(charactersIn: "\'")
        let DESC_1 = "<p>"
        let DESC_2 = NSCharacterSet(charactersIn: "<")
        var theImg: NSString?
        var theTitle: NSString?
        var theDescription: NSString?

        
        let IMG="<img src='"
        theScanner.scanString(IMG, into: nil)
        
        theScanner.scanUpToCharacters(from: quoteSet as CharacterSet, into: &theImg) // took me an hour to figure this out!!!
        theScanner.scanUpTo(TITLE, into: nil)
        theScanner.scanString(TITLE, into: nil)
        theScanner.scanUpToCharacters(from: quoteSet as CharacterSet, into: &theTitle)
        theScanner.scanUpTo(DESC_1, into: nil)
        theScanner.scanString(DESC_1, into: nil)
        theScanner.scanUpToCharacters(from: DESC_2 as CharacterSet, into: &theDescription)
        
        let theLinkScanner = Scanner(string: curLinkElement as String)
        var theLink: NSString?
        let linkSet =  NSCharacterSet(charactersIn: " ")
        theLinkScanner.scanUpToCharacters(from: linkSet as CharacterSet, into: &theLink)

        // image, title, description.
        let url = NSURL(string: theImg! as String)
        let imageData = NSData(contentsOf: url! as URL)
        var image = UIImage(named:"ImageName")
            
            
            //let imageQueue = DispatchQueue(label: "Image Queue", attributes: .concurrent)
            DispatchQueue.main.async {
                // get image from the Web
                image = UIImage(data: imageData! as Data)
                let deck:Deck = SharingDeck.sharedDeck.getDeck()!
                deck.addCard(newQuestion: theTitle! as String , newAnswer: theDescription! as String, newImage: image!, newUrl: theLink! as String)
                SharingDeck.sharedDeck.setDeck(newDeck: deck)
                self.tableView.reloadData()
            }
        
            if(theTitle == nil && theDescription != nil){
                theTitle = theDescription
            }
            if(theDescription == nil && theTitle != nil){
                theDescription = theTitle
            }
        


        }
        
    }
    
    
    func parseXML() {
        let parser = XMLParser(data: dataStore as Data)
        parser.delegate = self;      // don't forget to set the delegate for the parser
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == ELEMENT_NAME {
            processingElement = true // we are processing the "item" element
        }
        else if elementName == LINK_NAME {
            processingLinkElement = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if processingElement {
            currentElement += string
        }
        else if processingLinkElement {
            currentLinkElement += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == ELEMENT_NAME {

            readWebElements(curElement: currentElement as NSString, curLinkElement: currentLinkElement as NSString)
            //take element then scan it and add it.
            processingElement = false
            processingLinkElement = false
            currentElement = ""
            currentLinkElement = ""
        }
    } // didEndElement
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parser error " + String(describing: parseError))
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //return length of list here.
        let deck:Deck = SharingDeck.sharedDeck.getDeck()!
        return deck.getLength()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "CardTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CardTableViewCell else {
            fatalError("Dequeued cell is not an instance of CardTableViewCell")
        }
        let deck:Deck = SharingDeck.sharedDeck.getDeck()!
        let card = deck.getElementAtIndex(index: indexPath.row)
        
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
            SharingDeck.sharedDeck.getDeck()?.setCard(index: indexPath.row)
            SharingDeck.sharedDeck.getDeck()?.deleteCurrentCard()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            

        }
    }
    


}
