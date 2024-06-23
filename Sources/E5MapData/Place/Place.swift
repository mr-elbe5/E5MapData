/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import CloudKit
import E5Data

open class Place : UUIDObject, Comparable{
    
    public static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func < (lhs: Place, rhs: Place) -> Bool {
        AppState.shared.sortAscending ? lhs.creationDate < rhs.creationDate : lhs.creationDate > rhs.creationDate
    }
    
    public static var recordMetaKeys = ["uuid"]
    public static var recordDataKeys = ["uuid", "json"]
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case creationDate
        case timestamp //deprecated
        case name
        case address
        case note //deprecated
        case media //deprecated
        case items
    }
    public var coordinate: CLLocationCoordinate2D
    public var altitude: Double
    public var creationDate: Date
    public var mapPoint: CGPoint
    public var name : String = ""
    public var address : String = ""
    public var items : PlaceItemList
    public var _coordinateRegion: CoordinateRegion? = nil
    
    public var itemCount: Int{
        items.count
    }
    
    public var imageCount: Int{
        var count = 0
        for item in items{
            if item.type == .image{
                count += 1
            }
        }
        return count
    }
    
    public var hasItems : Bool{
        !items.isEmpty
    }
    
    public var allItemsSelected: Bool{
        items.allSelected
    }
    
    public var hasMedia : Bool{
        items.first(where: {
            [.image, .video, .audio].contains($0.type)
        }) != nil
    }
    
    public var hasTrack : Bool{
        items.first(where: {
            $0.type == .track
        }) != nil
    }
    
    public var hasNote : Bool{
        items.first(where: {
            $0.type == .note
        }) != nil
    }
    
    public var tracks: TrackList{
        items.filter({
            $0.type == .track
        }) as! Array<TrackItem>
    }
    
    public var images: ImageList{
        items.filter({
            $0.type == .image
        }) as! Array<ImageItem>
    }
    
    public var notes: Array<NoteItem>{
        items.filter({
            $0.type == .note
        }) as! Array<NoteItem>
    }
    
    public var fileItems : FileItemList{
        items.filter({
            $0 is FileItem
        }) as! FileItemList
    }
    
    public var coordinateRegion: CoordinateRegion{
        get{
            if _coordinateRegion == nil{
                _coordinateRegion = coordinate.coordinateRegion(radiusMeters: Preferences.shared.maxPlaceMergeDistance)
            }
            return _coordinateRegion!
        }
    }
    
    public var recordId : CKRecord.ID{
        get{
            CKRecord.ID(recordName: id.uuidString)
        }
    }
    
    public var dataRecord: CKRecord{
        get{
            let record = CKRecord(recordType: CKRecord.placeType, recordID: recordId)
            record["uuid"] = id.uuidString
            record["json"] = self.toJSON()
            return record
        }
    }
    
    public init(coordinate: CLLocationCoordinate2D){
        items = PlaceItemList()
        mapPoint = CGPoint(coordinate)
        self.coordinate = coordinate
        altitude = 0
        creationDate = Date.localDate
        super.init()
        evaluatePlacemark(){}
    }
    
    required public init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        let longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPoint = CGPoint(coordinate)
        altitude = try values.decodeIfPresent(CLLocationDistance.self, forKey: .altitude) ?? 0
        creationDate = try values.decodeIfPresent(Date.self, forKeys: [.creationDate, .timestamp]) ?? Date.localDate
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.items = try values.decodeIfPresent(Array<PlaceItemMetaData>.self, forKeys: [.items, .media])?.toItemList() ?? PlaceItemList()
        try super.init(from: decoder)
        for item in items{
            item.place = self
        }
        items.sort()
        if name.isEmpty || address.isEmpty{
            evaluatePlacemark(){}
        }
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        var metaList = Array<PlaceItemMetaData>()
        metaList.loadItemList(items: self.items)
        try container.encode(metaList, forKey: .items)
    }
    
    public func evaluatePlacemark(_ onFinish: @escaping() -> Void){
        print("getting placemark for \(name)")
        PlacemarkService.shared.getPlacemark(for: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)){ result in
            if let placemark = result{
                self.name = placemark.nameString ?? ""
                print("name is \(self.name)")
                self.address = placemark.locationString
            }
            else{
                print("no result")
            }
            onFinish()
        }
        
    }
    
    public func resetCoordinateRegion(){
        _coordinateRegion = nil
    }
    
    public func item(at idx: Int) -> PlaceItem{
        items[idx]
    }
    
    public func selectAllItems(){
        items.selectAll()
    }
    
    public func deselectAllItems(){
        items.deselectAll()
    }
    
    public func addItem(item: PlaceItem){
        if !items.containsEqual(item){
            item.place = self
            items.append(item)
        }
    }
    
    public func getItem(id: UUID) -> PlaceItem?{
        items.first(where:{
            $0.id == id
        })
    }
    
    public func deleteItem(item: PlaceItem){
        item.prepareDelete()
        items.remove(item)
    }
    
    public func deleteAllItems(){
        for item in items{
            item.prepareDelete()
        }
        items.removeAllItems()
    }
    
    public func sortItems(){
        items.sort()
    }
    
    public func mergePlace(from sourcePlace: Place){
        for sourceItem in sourcePlace.items{
            if !items.containsEqual(sourceItem){
                items.append(sourceItem)
            }
        }
        items.sort()
    }
    
}

