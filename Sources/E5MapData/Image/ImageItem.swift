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
    
    public enum CodingKeys: String, CodingKey {
        case metaData
    }
    
    override public var type : LocatedItemType{
        .image
    }
    
    override public init(){
        super.init()
        fileName = "img_\(id).jpg"
    }
    
    public var metaData: ImageMetaData? = nil
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        metaData = try values.decodeIfPresent(ImageMetaData.self, forKey: .metaData)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metaData, forKey: .metaData)
        try super.encode(to: encoder)
    }
    
    public func readMetaData(){
        if let data = FileManager.default.readFile(url: fileURL){
            metaData = ImageMetaData()
            metaData?.readData(data: data)
        }
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


