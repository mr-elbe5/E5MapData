/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import E5Data

open class ImageItem : FileItem{
    
    override public var type : PlaceItemType{
        .image
    }
    
    override public init(){
        super.init()
        fileName = "img_\(id).jpg"
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
#if os(macOS)
    public func getImage() -> NSImage?{
        if let data = getFile(){
            return NSImage(data: data)
        } else{
            return nil
        }
    }
#elseif os(iOS)
    public func getImage() -> UIImage?{
        if let data = getFile(){
            return UIImage(data: data)
        } else{
            return nil
        }
    }
#endif
    
}

public protocol ImageDelegate{
    func viewImage(image: ImageItem)
}

public typealias ImageList = Array<ImageItem>

extension ImageList{
    
    public mutating func remove(_ image: ImageItem){
        for idx in 0..<self.count{
            if self[idx].equals(image){
                self.remove(at: idx)
                return
            }
        }
    }
    
}


