//
//  TabViewController.swift
//  SistemiDigitali
//
//  Created by Dario De Nardi on 05/02/21.
//

import UIKit
import GuitarChords
import Firebase
import TensorFlowLite

class TabViewController: UIViewController {
    
    @IBOutlet weak var tabImage: UIImageView!
    
    var stringaDiPassaggio: String = String()
    var interpreter: Interpreter!
    var inputArray: [[[[Float32]]]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("🟢", #function)
        
        do {
            // input tensor [1, 192, 9, 1]
            // output tensor [1, 6, 19]
            var i = 1
            for element in self.inputArray {
                
                var inputData = Data()
                for element2 in element {
                    for element3 in element2 {
                        for element4 in element3 {
                            var f = Float32(element4)
                            let elementSize = MemoryLayout.size(ofValue: f)
                            var bytes = [UInt8](repeating: 0, count: elementSize)
                            memcpy(&bytes, &f, elementSize)
                            inputData.append(&bytes, count: elementSize)
                        }
                    }
                }
                
                try self.interpreter.allocateTensors()
                try self.interpreter.copy(inputData, toInputAt: 0)
                try self.interpreter.invoke()
                
                let output = try self.interpreter.output(at: 0)
                let probabilities =
                        UnsafeMutableBufferPointer<Float32>.allocate(capacity: 114)
                output.data.copyBytes(to: probabilities)
                
                print("IMG", i)
                var z = 0
                for y in 0...5 {
                    print("CORDA", (y+1))
                    for _ in 0...18 {
                        print(probabilities[z])
                        z = z + 1
                    }
                }
                
                i = i + 1
            }
            
        } catch {
            print("Unexpected predictions")
            return
        }
        
        // https://github.com/BeauNouvelle/SwiftyGuitarChords
        let chordPosition = GuitarChords.all.matching(key: .c).matching(suffix: .major).first!
        let frame = CGRect(x: 0, y: 0, width: 100, height: 150) // I find these sizes to be good.
        let layer = chordPosition.layer(rect: frame, showFingers: true, showChordName: true, forScreen: true)
        tabImage.image = layer.image() // might be exepensive. Use CALayer when possible.
    }
    
}
