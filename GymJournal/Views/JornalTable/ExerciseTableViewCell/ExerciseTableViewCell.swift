//
//  ExerciseTableViewCell.swift
//  GymJournal
//
//  Created by Никита Суровцев on 27.12.23.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {


    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var setLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        exerciseLabel.textColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
