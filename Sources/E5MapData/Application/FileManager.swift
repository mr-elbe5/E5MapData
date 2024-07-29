/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

extension FileManager {
    
    public static var mediaDirURL : URL = privateURL.appendingPathComponent("media")
    public static var tilesDirURL : URL = privateURL.appendingPathComponent("tiles")
    
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
