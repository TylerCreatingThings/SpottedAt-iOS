//
//  CardTableViewCell.swift
//  fark3230_a4
//
//  Created by Tyler Farkas on 2018-03-03.
//  Copyright © 2018 Tyler Farkas. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    //MARK:: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var mainBackground: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
