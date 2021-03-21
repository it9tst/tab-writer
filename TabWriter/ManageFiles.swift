//
//  ManageFiles.swift
//  TabWriter
//
//  Created by Dario De Nardi on 06/03/21.
//

import Foundation

class ManageFiles {
    
    // generate path where you want to save that recording as myRecording.m4a
    static func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    static func getFileUrl(filename: String) -> URL
    {
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        return filePath
    }
    
}
