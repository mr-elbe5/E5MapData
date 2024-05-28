/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

extension FileManager {
    
    public static var mediaDirURL : URL = FileManager.privateURL.appendingPathComponent("media")
    public static var tilesDirURL : URL = privateURL.appendingPathComponent("tiles")
    public static var exportGpxDirURL = documentURL.appendingPathComponent("gpx")
    public static var exportMediaDirURL = documentURL.appendingPathComponent("media")
    public static var backupDirURL = documentURL.appendingPathComponent("backup")
    
    public func initializeAppDirs() {
        try! FileManager.default.createDirectory(at: FileManager.tilesDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.mediaDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.exportGpxDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.backupDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.exportMediaDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func logFileInfo(){
        var names = listAllFiles(dirPath: FileManager.default.temporaryDirectory.path)
        for name in names{
            print(name)
        }
        names = listAllFiles(dirPath: FileManager.mediaDirURL.path)
        for name in names{
            print(name)
        }
    }
    
}
