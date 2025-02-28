//
//  HomeCell.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import UIKit

class HomeCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var flower: Flower?=nil {
        didSet {
            titleLabel.text = flower?.name
            iconImageView.image = UIImage(named: flower?.icon ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
