//
//  ListViewBasicTableViewCell.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/12.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit

class ListViewBasicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var administrativeAreaLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var favoriteStarButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
