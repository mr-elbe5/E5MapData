/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data
import UniformTypeIdentifiers

open class ImageMetaData: Codable{
    
    public static var exifDateFormatter : DateFormatter{
            get{
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = .none
                dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                return dateFormatter
            }
        }
    
    public enum CodingKeys: String, CodingKey {
        case url
        case utType
        case fileCreationDate
        case fileModificationDate
        case exifLensModel
        case exifWidth
        case exifHeight
        case exifLatitude
        case exifLongitude
        case exifAltitude
        case exifCreationDate
    }
    
    public var url: URL
    public var utType: UTType
    public var fileCreationDate: Date? = nil
    public var fileModificationDate: Date? = nil
    public var exifLensModel = ""
    public var exifWidth : Int = 0
    public var exifHeight : Int = 0
    public var exifLatitude: Double = 0.0
    public var exifLongitude: Double = 0.0
    public var exifAltitude: Double = 0.0
    public var exifCreationDate : Date? = nil
    
    public var name: String{
        url.lastPathComponent.pathWithoutExtension()
    }
    
    public var pathExtension: String{
        url.pathExtension.lowercased()
    }
    
    public var creationDate: Date?{
        exifCreationDate ?? fileCreationDate
    }
    
    public var creationDateString: String{
        creationDate?.dateTimeString() ?? ""
    }
    
    public init(url: URL){
        self.url = url
        self.utType = url.utType ?? .url
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decode(URL.self, forKey: .url)
        utType = try values.decodeIfPresent(UTType.self, forKey: .utType) ?? url.utType ?? .url
        fileCreationDate = try values.decodeIfPresent(Date.self, forKey: .fileCreationDate)
        fileModificationDate = try values.decodeIfPresent(Date.self, forKey: .fileModificationDate)
        exifLensModel = try values.decodeIfPresent(String.self, forKey: .exifLensModel) ?? ""
        exifWidth = try values.decodeIfPresent(Int.self, forKey: .exifWidth) ?? 0
        exifHeight = try values.decodeIfPresent(Int.self, forKey: .exifHeight) ?? 0
        exifLatitude = try values.decodeIfPresent(Double.self, forKey: .exifLatitude) ?? 0.0
        exifLongitude = try values.decodeIfPresent(Double.self, forKey: .exifLongitude) ?? 0.0
        exifAltitude = try values.decodeIfPresent(Double.self, forKey: .exifAltitude) ?? 0.0
        exifCreationDate = try values.decodeIfPresent(Date.self, forKey: .exifCreationDate)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(utType, forKey: .utType)
        try container.encode(fileCreationDate, forKey: .fileCreationDate)
        try container.encode(fileModificationDate, forKey: .fileModificationDate)
        try container.encode(exifLensModel, forKey: .exifLensModel)
        try container.encode(exifWidth, forKey: .exifWidth)
        try container.encode(exifHeight, forKey: .exifHeight)
        try container.encode(exifLatitude, forKey: .exifLatitude)
        try container.encode(exifLongitude, forKey: .exifLongitude)
        try container.encode(exifAltitude, forKey: .exifAltitude)
        try container.encode(exifCreationDate, forKey: .exifCreationDate)
    }
    
}


