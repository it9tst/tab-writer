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

class HomeViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordImage: UIImageView!
    
    var inputArray: [[[[Float32]]]] = []
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
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
        
        self.recordLabel.textColor = UIColor(named: "White")
        self.timerLabel.textColor = UIColor(named: "White")
        
        recordLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        timerLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
        
        let ok = TfliteModel.loadModel(on: self)
        if (ok == false) {
            ErrorReporting.showMessage(title: "Error", msg: "Error initializing TensorFlow Lite.", on: self)
        }
        
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
    
    // Setup the recorder
    func setup_recorder()
    {
        if (isAudioRecordingGranted == true)
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatFLAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                
                let year = Calendar.current.component(.year, from: Date())
                let month = Calendar.current.component(.month, from: Date())
                let day = Calendar.current.component(.day, from: Date())
                let hour = Calendar.current.component(.hour, from: Date())
                let minute = Calendar.current.component(.minute, from: Date())
                let second = Calendar.current.component(.second, from: Date())
                
                filename = "Recording_" + String(year) + "_" + String(format: "%02d",month) + "_" + String(format: "%02d", day) + "_" + String(format: "%02d", hour) + "_" + String(format: "%02d", minute) + String(format: "%02d", second)
                
                audioRecorder = try AVAudioRecorder(url: ManageFiles.getFileUrl(filename: filename + ".m4a"), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                
                meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
                audioRecorder.record()
            }
            catch let error {
                ErrorReporting.showMessage(title: "Error", msg: error.localizedDescription, on: self)
                self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
                
                self.recordLabel.textColor = UIColor(named: "White")
                
                self.recordImage.image = UIImage(named: "rec_button_off")
            }
        }
        else
        {
            ErrorReporting.showMessage(title: "Error", msg: "Don't have access to use your microphone.", on: self)
            
            self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
            
            self.recordLabel.textColor = UIColor(named: "White")
            
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
            let path = ManageFiles.getFileUrl(filename: filename).absoluteString
            MobileFFmpeg.execute("-i " + path + ".m4a" + " -acodec pcm_u8 -ar 44100 " + path.replacingOccurrences(of: ".m4a", with: "") + ".wav")
            do
            {
                let fileManager = FileManager.default
                try fileManager.removeItem(at: (path + ".m4a").asURL())
            }catch let error {
                print(error.localizedDescription)
            }
        }
        else
        {
            ErrorReporting.showMessage(title: "Error", msg: "Recording failed.", on: self)
            self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
            
            self.recordLabel.textColor = UIColor(named: "White")
            
            self.recordImage.image = UIImage(named: "rec_button_off")
        }
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
        
        if (self.recordLabel.text == "CLICCA IL BOTTONE PER REGISTRARE") {
            
            self.recordLabel.text = "STO REGISTRANDO"
            
            self.recordLabel.textColor = UIColor(named: "Red")
            
            self.recordImage.image = UIImage(named: "rec_button_on")
            
            setup_recorder()
        } else if (self.recordLabel.text == "STO REGISTRANDO") {
            
            self.recordLabel.text = "STO PENSANDO"
            
            self.recordLabel.textColor = UIColor(named: "Blue")
            
            finishAudioRecording(success: true)
            
            let urlAudioWav = ManageFiles.getFileUrl(filename: filename + ".wav")
            
            request(audioFilePath: urlAudioWav, withIdentifier: "segueHomeToResultViewController")
            
        }
    }
    
    func request(audioFilePath: URL, withIdentifier: String) {
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
                    
                    self.performSegue(withIdentifier: withIdentifier, sender: nil)
                    
                    self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
                
                    self.recordLabel.textColor = UIColor(named: "White")
                
                    self.recordImage.image = UIImage(named: "rec_button_off")
                    
                //}   catch {
                //    print(error.localizedDescription)
                //}
            
            case .failure(let encodingError):
                ErrorReporting.showMessage(title: "Error", msg: "\(encodingError)", on: self)
                
                self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
                
                self.recordLabel.textColor = UIColor(named: "White")
                
                self.recordImage.image = UIImage(named: "rec_button_off")
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        // Controllo se il segue ha un identifier o meno, se non ce l'ha esco dalla func
        guard let identifier = segue.identifier else {
            print("🟢 il segue non ha un identifier, esco dal prepareForSegue")
            return
        }
        
        // Controllo l'identifier perché potrebbero esserci più di un Segue che parte da questo VC
        switch identifier {
        case "segueHomeToResultViewController":
            // Accedo al destinationViewController del segue e lo casto del tipo di dato opportuno
            // Modifico la variabile d'appoggio con il contenuto che voglio inviare
            let vcDestinazione = segue.destination as! TabViewController
            vcDestinazione.interpreter = TfliteModel.interpreter
            vcDestinazione.inputArray = self.inputArray
            vcDestinazione.fileName = self.filename
            
            default:
                return
        }
        
    }
    
}
