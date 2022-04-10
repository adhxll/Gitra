//
//  OnBoardingAnimation.swift
//  Gitra
//
//  Created by Samuel Maynard on 08/06/21.
//

import UIKit
import AVFoundation

class OnBoardingAnimation: UIViewController{
    
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
