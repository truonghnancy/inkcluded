//
//  GroupsTableViewCell.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/29/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {


    @IBOutlet var groupName: UILabel!
    @IBOutlet var groupDetails: UILabel!
    @IBOutlet var groupIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
