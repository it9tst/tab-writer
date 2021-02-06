//
//  TabViewController.swift
//  SistemiDigitali
//
//  Created by Dario De Nardi on 05/02/21.
//

import UIKit
import GuitarChords

class TabViewController: UIViewController {
    
    @IBOutlet weak var tabImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("🟢", #function)
        
        // https://github.com/BeauNouvelle/SwiftyGuitarChords
        let chordPosition = GuitarChords.all.matching(key: .c).matching(suffix: .major).first!
        let frame = CGRect(x: 0, y: 0, width: 100, height: 150) // I find these sizes to be good.
        let layer = chordPosition.layer(rect: frame, showFingers: true, showChordName: true, forScreen: true)
        tabImage.image = layer.image() // might be exepensive. Use CALayer when possible.
    }
    
}
