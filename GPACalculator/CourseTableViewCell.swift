//
//  CourseTableViewCell.swift
//  Final_Exam
//
//  Created by Gregory Hagins II on 5/6/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit

protocol CourseCellDelegate {
    func deleteButton(cell: UITableViewCell)
}

class CourseTableViewCell: UITableViewCell {

    var delegate: CourseCellDelegate?
    
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var crLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteButton(_ sender: Any) {
         delegate?.deleteButton(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
