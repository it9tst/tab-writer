//
//  HomeViewController.swift
//  SistemiDigitali
//
//  Created by Dario De Nardi on 04/02/21.
//

import UIKit
import AVFoundation
import PythonKit
import CoreML
import Vision

class HomeViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordImage: UIImageView!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    //var filename: String = ""
    var filename = "Recording_2021_02_05_21_48.m4a"
    
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
        
        recordLabel.font = UIFont(name: "Arlon-Regular", size: 20)
        timerLabel.font =  UIFont(name: "Arlon-Regular", size: 22)
        
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

    func getFileUrl() -> URL
    {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        
        filename = "Recording_" + String(year) + "_" + String(format: "%02d",month) + "_" + String(format: "%02d", day) + "_" + String(format: "%02d", hour) + "_" + String(format: "%02d", minute) + ".m4a"
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
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
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
            self.recordLabel.textColor = #colorLiteral(red: 0.7280769348, green: 0.2136592269, blue: 0.3053612411, alpha: 1)
            self.recordImage.image = UIImage(named: "rec_button_on")
            
            //setup_recorder()
            //meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            //audioRecorder.record()
            //isRecording = true
            
        } else if (self.recordLabel.text == "STO REGISTRANDO") {
            
            //finishAudioRecording(success: true)
            //isRecording = false
            
            self.recordLabel.text = "STO PENSANDO"
            self.recordLabel.textColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
            
            
            
            self.performSegue(withIdentifier: "segueToResultViewController", sender: nil)
            
            self.recordLabel.text = "CLICCA IL BOTTONE PER REGISTRARE"
            self.recordLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            self.recordImage.image = UIImage(named: "rec_button_off")
            
        }
    }
    
}
