//
//  SettingTableViewCell.swift
//  Gitra
//
//  Created by Yahya Ayyash Asaduddin on 16/04/22.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    static let identifier: String = "SettingTableViewCell"
    private let numberLabelWidth: CGFloat = 30
    private let margin: CGFloat = 20
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = .ColorLibrary.blackAccent
        label.backgroundColor = .ColorLibrary.yellowAccent
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(numberLabel)
        contentView.addSubview(descriptionLabel)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupConstraints() {
        let marginGuide = contentView.layoutMarginsGuide
        
        // Number Label Constraint
        numberLabel.widthAnchor.constraint(equalToConstant: numberLabelWidth).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        numberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        
        // Description Label Constraint
        descriptionLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: margin).isActive = true
        descriptionLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    }
    
    public func setupContent(for row: Int, text: String) {
        numberLabel.text = "\(row)"
        descriptionLabel.text = text
    }
}
