//
//  WordCell.swift
//  AideA_support
//
//  Created by AppCircle on 2017/11/01.
//  Copyright © 2017年 NichibiAppCircle. All rights reserved.
//

import UIKit

class WordCell: UITableViewCell
{
    @IBOutlet weak var lblWord: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
