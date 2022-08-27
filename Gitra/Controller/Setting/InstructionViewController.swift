//
//  InstructionViewController.swift
//  Gitra
//
//  Created by Yahya Ayyash on 16/06/21.
//

import UIKit
import Foundation

class InstructionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var instructionArray = [String]()
    var senderPage: Int?
    var titleText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        tableView.delegate = self
        tableView.dataSource = self
        sourceParent(senderPage ?? 0)
        self.title = titleText
    }
    
    func sourceParent(_ index: Int) {
        switch index {
        case 0 :
            titleText = "Voice Command Mode"
            instructionArray = ["1. Wait until you can hear the cue to speak sound.\n",
                                "2. Say which chord do you want to play (e.g. C Major), you will be directed into the chord detail page.\n",
                                "3. On the chord detail page, say 'Next' if you want to go to the next string, and 'Repeat' if you want to repeat the note sound.\n",
                                "4. There is a toolbar with 'Previous', 'Next', and 'Repeat' button on the bottom of the screen."
               ]
        case 1 :
            titleText = "Picker Mode"
            instructionArray = ["1. If you are using picker mode, on the main page there will be a picker which you can adjust to find the chord you are looking for.\n",
                                "2. There are 3 section that you can adjust, roots, quality, and tension.\n",
                                "3. You can adjust the picker by swiping up or down on each section.",
               ]
        case 2 :
            titleText = "Automatic Tuner"
            instructionArray = ["1. Press the start button in the middle of the screen to start the tuner.\n",
                                "2. Pluck a string and hear the instructions on how to tune the selected string.\n",
                                "3. Tune the string until you hear the sound cue, indicating that the string is tuned.\n",
                                "4. Press the stop button in the middle of the screen to turn off the tuner."
            ]
        default :
            break
        }
    }
}

extension InstructionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "instructionCell") as! InstructionListTableViewCell
        cell.listArray = instructionArray
        cell.listInterface()
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "How to use " + titleText
    }
}
