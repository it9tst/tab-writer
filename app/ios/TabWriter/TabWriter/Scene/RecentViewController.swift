//
//  RecentViewController.swift
//  SistemiDigitali
//
//  Created by Dario De Nardi on 05/02/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class RecentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var fileList: [String] = []
    var inputArray: [[[[Float32]]]] = []
    var filename = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("🟢", #function)
        ManageFiles.clearAllFile()
        
        tableView.backgroundColor = UIColor(named: "Grey")
        
        findAllRecording()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        findAllRecording()
        self.tableView.reloadData()
    }
    
    func findAllRecording() {
        fileList = []
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            for file in fileURLs {
                //print(file)
                fileList.append(ManageFiles.fileName(fileName: file.absoluteString))
            }
            
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
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
                    
                //}   catch {
                //    print(error.localizedDescription)
                //}
            
            case .failure(let encodingError):
                ErrorReporting.showMessage(title: "Error", msg: "\(encodingError)", on: self)
            }
            
        }
    }
    
} //RecentViewController

extension RecentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        filename = fileList[indexPath.row]
        
        let urlAudioM4a = ManageFiles.getFileUrl(filename: fileList[indexPath.row] + ".m4a")
        
        request(audioFilePath: urlAudioM4a, withIdentifier: "segueTabToResultViewController")
    }
    
}

extension RecentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = UIColor(named: "Grey")
        
        cell.textLabel?.text = fileList[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        // Controllo se il segue ha un identifier o meno, se non ce l'ha esco dalla func
        guard let identifier = segue.identifier else {
            print("🟢 il segue non ha un identifier, esco dal prepareForSegue")
            return
        }
        
        // Controllo l'identifier perché potrebbero esserci più di un Segue che parte da questo VC
        switch identifier {
        case "segueTabToResultViewController":
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
