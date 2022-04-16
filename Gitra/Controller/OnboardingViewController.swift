//
//  OnboardingViewController.swift
//  Gitra
//
//  Created by Adhella Subalie on 16/04/22.
//

import Foundation

import UIKit
import AVFoundation

class OnboardingViewController: UIViewController{
    
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var sentence1 : UILabel!
    @IBOutlet weak var sentence2 : UILabel!
    @IBOutlet weak var sentence3 : UILabel!
    @IBOutlet weak var proceedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        proceedBtn.titleLabel?.text = "Proceed"
    }
    
    @IBAction func buttonDidTapped(_ sender: UIButton){
        self.performSegue(withIdentifier: "seguetochord", sender: nil)
    }
}
