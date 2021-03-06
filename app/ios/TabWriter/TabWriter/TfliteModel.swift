//
//  MusicRequest.swift
//  TabWriter
//
//  Created by Dario De Nardi on 06/03/21.
//

import Foundation
import Firebase
import TensorFlowLite

class TfliteModel {
        
    static var interpreter: Interpreter!
    
    static func loadModel(`on` controller: UIViewController) -> Bool {
        
        guard let modelPath = Bundle.main.path(forResource: "tabCNN", ofType: "tflite")
          else {
            // Invalid model path
            ErrorReporting.showMessage(title: "Error", msg: "Invalid model path.", on: controller)
            return false
          }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
          } catch {
            ErrorReporting.showMessage(title: "Error", msg: "Error initializing TensorFlow Lite.", on: controller)
              return false
          }
        
        return true
    }
    
}
