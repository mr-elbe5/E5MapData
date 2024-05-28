/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

open class PlaceItemMetaData : Identifiable, Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    public var type : PlaceItemType
    public var data : PlaceItem
    
    public init(item: PlaceItem){
        self.type = item.type
        self.data = item
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(PlaceItemType.self, forKey: .type)
        switch type{
        case .audio:
            data = try values.decode(AudioItem.self, forKey: .data)
        case .image:
            data = try values.decode(ImageItem.self, forKey: .data)
        case .video:
            data = try values.decode(VideoItem.self, forKey: .data)
        case .track:
            data = try values.decode(TrackItem.self, forKey: .data)
        case .note:
            data = try values.decode(NoteItem.self, forKey: .data)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}

extension Array<PlaceItemMetaData>{
    
    public mutating func loadItemList(items: PlaceItemList){
        removeAll()
        for i in 0..<items.count{
            append(PlaceItemMetaData(item: items[i]))
        }
    }
    
    public func toItemList() -> PlaceItemList{
        var items = PlaceItemList()
        for metaItem in self{
            items.append(metaItem.data)
        }
        return items
    }
    
}
