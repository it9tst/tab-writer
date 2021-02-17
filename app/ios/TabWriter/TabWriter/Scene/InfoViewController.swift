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
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.creditsLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.creditsLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                self.creditsLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                self.creditsLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            }
        } else {
            self.creditsLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            self.creditsLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        }
    }
    
}
