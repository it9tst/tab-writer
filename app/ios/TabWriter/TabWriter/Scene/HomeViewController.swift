//
//  HomeViewController.swift
//  SistemiDigitali
//
//  Created by Dario De Nardi on 04/02/21.
//

import UIKit
import AVFoundation
import CoreMedia
import Alamofire
import SwiftyJSON
import Firebase
import TensorFlowLite

class HomeViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordImage: UIImageView!
    
    var interpreter: Interpreter!
    var inputArray: [[[[Float32]]]] = []
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var filename = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /*for family: String in UIFont.familyNames
                {
                    print(family)
                    for names: String in UIFont.fontNames(forFamilyName: family)
                    {
                        print("== \(names)")
                    }
                }*/
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.recordLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.timerLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                self.timerLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            }
        } else {
            self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            self.timerLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        }
        
        recordLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        timerLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
        
        let ok = loadModel()
        print("🟢", ok)
        
        check_record_permission()
        
    }
    
    // check record permission
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
            })
            break
        default:
            break
        }
    }
    
    // generate path where you want to save that recording as myRecording.m4a
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getFileUrl(filename: String) -> URL
    {
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        // print(filePath)
        return filePath
    }
    
    // Setup the recorder
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey:AVAudioQuality.low.rawValue
                ]
                
                let year = Calendar.current.component(.year, from: Date())
                let month = Calendar.current.component(.month, from: Date())
                let day = Calendar.current.component(.day, from: Date())
                let hour = Calendar.current.component(.hour, from: Date())
                let minute = Calendar.current.component(.minute, from: Date())
                
                filename = "Recording_" + String(year) + "_" + String(format: "%02d",month) + "_" + String(format: "%02d", day) + "_" + String(format: "%02d", hour) + "_" + String(format: "%02d", minute)
                
                audioRecorder = try AVAudioRecorder(url: getFileUrl(filename: filename + ".m4a"), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
                if #available(iOS 13.0, *) {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        self.recordLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    } else {
                        self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                    }
                } else {
                    self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                }
                self.recordImage.image = UIImage(named: "rec_button_off")
            }
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
            self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.recordLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                }
            } else {
                self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            }
            self.recordImage.image = UIImage(named: "rec_button_off")
        }
    }
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            self.timerLabel.text = "00:00"
            //print("recorded successfully.")
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
            self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.recordLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                }
            } else {
                self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            }
            self.recordImage.image = UIImage(named: "rec_button_off")
        }
    }
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
        _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            //let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            self.timerLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    @IBAction func recordButton_touchUpInside(_ sender: UIButton) {
        print("🟢", #function)
        
        if (self.recordLabel.text == "CLICCA IL BOTTONE PER REGISTRARE") {
            
            self.recordLabel.text = "STO REGISTRANDO"
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.recordLabel.textColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
                } else {
                    self.recordLabel.textColor = #colorLiteral(red: 0.7280769348, green: 0.2136592269, blue: 0.3053612411, alpha: 1)
                }
            } else {
                self.recordLabel.textColor = #colorLiteral(red: 0.7280769348, green: 0.2136592269, blue: 0.3053612411, alpha: 1)
            }
            self.recordImage.image = UIImage(named: "rec_button_on")
            
            setup_recorder()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            audioRecorder.record()
            isRecording = true
            
        } else if (self.recordLabel.text == "STO REGISTRANDO") {
            
            self.recordLabel.text = "STO PENSANDO"
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.recordLabel.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                } else {
                    self.recordLabel.textColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
                }
            } else {
                self.recordLabel.textColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
            }
            
            finishAudioRecording(success: true)
            isRecording = false
            
            let urlAudioM4a = getFileUrl(filename: filename + ".m4a")
            
            request(audioFilePath: urlAudioM4a)
            
        }
    }
    
    func request(audioFilePath: URL) {
        let url = URL(string: "http://0.0.0.0:5000/upload/")!

        let headers: HTTPHeaders = [
                "content-type": "multipart/form-data; boundary=---011000010111000001101001",
                "accept": "application/json"
        ]

        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(audioFilePath, withName: "file")
            
        }, to: url, headers: headers)
        .responseJSON { response in
            switch response.result {
            case .success:
                //do{
                    //let json = try JSON(data: response.data!)
                    //print(json)
                    
                    let decoder = JSONDecoder()
                    do {
                        self.inputArray = try decoder.decode([[[[Float32]]]].self, from: response.data!)
                        //debugPrint(inputArray)
                      } catch {
                          print("Unexpected runtime error. Array")
                          return
                      }
                    
                    self.performSegue(withIdentifier: "segueToResultViewController", sender: nil)
                    
                    self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
                    if #available(iOS 13.0, *) {
                        if self.traitCollection.userInterfaceStyle == .dark {
                            self.recordLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        } else {
                            self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                        }
                    } else {
                        self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                    }
                    self.recordImage.image = UIImage(named: "rec_button_off")
                    
                //}   catch {
                //    print(error.localizedDescription)
                //}
            
            case .failure(let encodingError):
                self.display_alert(msg_title: "Error", msg_desc: "\(encodingError)", action_title: "OK")
                //print("error:\(encodingError)")
                self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
                if #available(iOS 13.0, *) {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        self.recordLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    } else {
                        self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                    }
                } else {
                    self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
                }
                self.recordImage.image = UIImage(named: "rec_button_off")
            }
            
        }
    }
    
    private func loadModel() -> Bool {
        
        guard let modelPath = Bundle.main.path(forResource: "tabCNN", ofType: "tflite")
          else {
            // Invalid model path
            print("invalid model path")
            return false
          }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
          } catch {
            self.display_alert(msg_title: "Error", msg_desc: "Error initializing TensorFlow Lite", action_title: "OK")
            //print("Error initializing TensorFlow Lite: \(error.localizedDescription)")
              return false
          }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        // Controllo se il segue ha un identifier o meno, se non ce l'ha esco dalla func
        guard let identifier = segue.identifier else {
            print("🟢 il segue non ha un identifier, esco dal prepareForSegue")
            return
        }
        
        // Controllo l'identifier perché potrebbero esserci più di un Segue che parte da questo VC
        switch identifier {
        case "segueToResultViewController":
            // Accedo al destinationViewController del segue e lo casto del tipo di dato opportuno
            // Modifico la variabile d'appoggio con il contenuto che voglio inviare
            let vcDestinazione = segue.destination as! TabViewController
            vcDestinazione.interpreter = self.interpreter
            vcDestinazione.inputArray = self.inputArray
            vcDestinazione.fileName = self.filename
            
            default:
                return
        }
        
    }
    
}
