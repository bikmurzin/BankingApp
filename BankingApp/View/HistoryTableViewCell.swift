//
//  HistoryTableViewCell.swift
//  BankingApp
//
//  Created by User on 30.05.2023.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var operationTypeLabel: UILabel!
    @IBOutlet weak var operationNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
