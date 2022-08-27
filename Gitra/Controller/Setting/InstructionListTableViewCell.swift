//
//  InstructionListTableViewCell.swift
//  Gitra
//
//  Created by Yahya Ayyash on 16/06/21.
//

import UIKit

class InstructionListTableViewCell: UITableViewCell {

    @IBOutlet weak var instructionList: UILabel!
    var listArray = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func listInterface() {
        let joiner = "\n"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.firstLineHeadIndent = 0
        
        let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        listArray = listArray.map( { "\($0)" })
        let bulletListString = listArray.joined(separator: joiner)
        instructionList.attributedText = NSAttributedString(string: bulletListString, attributes: attributes)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
