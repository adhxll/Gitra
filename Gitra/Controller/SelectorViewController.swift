//
//  SelectorViewController.swift
//  Gitra
//
//  Created by Adhella Subalie on 16/04/22.
//

import UIKit

class SelectorViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initializeUserDefaults()
        navigateToPreferedPage()
    }
    
    func initializeUserDefaults() {
        if OnboardingHandler.shared.isFirstLaunch {
            defaults.set(0, forKey: "inputMode")
            defaults.set(1, forKey: "welcomeScreen")
            defaults.set(1, forKey: "inputCommand")
            defaults.set(1, forKey: "chordSpeed")
            OnboardingHandler.shared.isFirstLaunch = true
        }
    }
    
    func navigateToPreferedPage() {
        let value = defaults.integer(forKey: "welcomeScreen")
        if (value == 0) {
            performSegue(withIdentifier: "skipOnboarding", sender: nil)
        } else {
            performSegue(withIdentifier: "toOnboarding", sender: nil)
        }
    }
}
