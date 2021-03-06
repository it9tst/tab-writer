//
//  ManageFiles.swift
//  TabWriter
//
//  Created by Dario De Nardi on 06/03/21.
//

import Foundation

class ManageFiles {
    
    static func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    // generate path where you want to save that recording as myRecording.m4a
    static func getFileUrl(filename: String) -> URL
    {
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        // print(filePath)
        return filePath
    }
    
    static func fileName(fileName: String) -> String {
        return URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
    }
    
    static func clearAllFile() {
        let fileManager = FileManager.default
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            
        do
        {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
        
            for file in fileName {
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                try fileManager.removeItem(at: filePath)
            }
            
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
}
