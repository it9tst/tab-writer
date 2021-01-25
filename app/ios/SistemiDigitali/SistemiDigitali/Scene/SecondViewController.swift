//
//  SecondViewController.swift
//  SistemiDigitali
//
//  Created by Dario De Nardi on 25/01/21.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backButton_touchUpInside(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
