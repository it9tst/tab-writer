//
//  InfoViewController.swift
//  TabWriter
//
//  Created by Dario De Nardi on 17/02/21.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var creditsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("🟢", #function)
        
        let textColor = UIColor(named: "White")
        self.creditsLabel.textColor = textColor
    }
    
}
