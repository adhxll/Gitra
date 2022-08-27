//
//  CustomSwitch.swift
//  Gitra
//
//  Created by Yahya Ayyash Asaduddin on 16/04/22.
//

import UIKit

class CustomSwitch: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        onTintColor = .ColorLibrary.yellowAccent
        setOn(false, animated: true)
    }
    
    public func setupSwitch(_ sender: Any?, tag: Int, action: Selector) {
        self.tag = tag
        self.addTarget(sender, action: action, for: .valueChanged)
    }
}
