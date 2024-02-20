//
//  AddExersiceJournalTableViewCell.swift
//  GymJournal
//
//  Created by Никита Суровцев on 6.12.23.
//

import UIKit

class WorkoutCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        nameLabel.textColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
