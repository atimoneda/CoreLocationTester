//
//  LogManager.swift
//  CoreLocationTester
//
//  Created by Arnau Timoneda Heredia on 09/04/2019.
//  Copyright © 2019 Arnau Timoneda Heredia. All rights reserved.
//

import Foundation

class LogManager{
    static let sharedInstance = LogManager()
    private let FILENAME = "TEST"
    
    func generateFileURL() -> URL {
        let documentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirUrl.appendingPathComponent(FILENAME).appendingPathExtension("txt")
        
        return fileURL
    }
    
    func writeFileWith(line: String!){
        print("la linia que me llega es \(line!)" )
        
        let fileURL = generateFileURL()
        print("el path es : \(fileURL)")
        let oldText = readFile()
        let finalText = oldText + line
        do{
            try finalText.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
            print("escrito!")
        }catch let error as NSError {
            print("failed")
            print(error)
        }

    }
    
    func clearFile(){
        let fileURL = generateFileURL()
        print("el path es : \(fileURL)")
        do{
            try "".write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
            print("escrito!")
        }catch let error as NSError {
            print("failed")
            print(error)
        }
    }
    
    func readFile()->String{

        let filePath = generateFileURL()
        
        var result = "";
        do{
            result = try String(contentsOf: filePath)
            print("lo he leido! y es : \(result)")
        }catch let error as NSError {
            print(error)
        }
        return result
    }
    
    
    //Ejemplo Jesus.
//    func testFunc(){
//        let valuesSortedJoined = "algo para guardar"
//        let dataToSave =  valuesSortedJoined.data(using: .utf8)
//
//        if let dataToSave = dataToSave {
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let directoryURL = documentsDirectory.appendingPathComponent("DataLog.txt")
//            print("dir url path: \(directoryURL)")
//            print("Data to string: \(String(data: dataToSave, encoding: String.Encoding.utf8))")
//
//            var fileHandle: FileHandle?
//            if FileManager().fileExists(atPath: documentsDirectory.path) {
//                print("")
//                let titlesData = "pos esto nose que es".data(using: .utf8)
//                do {
//                    try dataToSave.write(to: directoryURL)
//                    print("se hace el write")
//                }
//                catch {}
//            }
//            fileHandle = FileHandle(forUpdatingAtPath: documentsDirectory.path)
//            fileHandle?.seekToEndOfFile()
//            fileHandle?.write(dataToSave)
//            fileHandle?.closeFile()
//            print("se ha guardado..")
//        }
//    }
}
