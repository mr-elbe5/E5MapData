/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import E5Data

open class AppData{
    
    public static var storeKey = "locations"
    
    public static var shared = AppData()
    
    public var places = PlaceList()
    
    public func resetCoordinateRegions() {
        for place in places{
            place.resetCoordinateRegion()
        }
    }
    
    public func createPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = addPlace(coordinate: coordinate)
        return place
    }
    
    public func addPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = Place(coordinate: coordinate)
        places.append(place)
        return place
    }
    
    public func deletePlace(_ place: Place){
        for idx in 0..<places.count{
            if places[idx].equals(place){
                place.deleteAllItems()
                places.remove(place)
                return
            }
        }
    }
    
    public func deleteAllPlaces(){
        for idx in 0..<places.count{
            places[idx].deleteAllItems()
        }
        places.removeAll()
    }
    
    public func getPlace(coordinate: CLLocationCoordinate2D) -> Place?{
        places.first(where:{
            $0.coordinateRegion.contains(coordinate: coordinate)
        })
    }
    
    public func getPlace(id: UUID) -> Place?{
        places.first(where:{
            $0.id == id
        })
    }
    
    // local persistance
    
    public func loadLocally(){
        if let list : PlaceList = UserDefaults.standard.load(forKey: AppData.storeKey){
            places = list
        }
        else{
            places = PlaceList()
        }
    }
    
    public func saveLocally(){
        UserDefaults.standard.save(forKey: AppData.storeKey, value: places)
    }
    
    // file persistance
    
    public func saveAsFile() -> URL?{
        let value = places.toJSON()
        let url = FileManager.tempURL.appendingPathComponent(AppData.storeKey + ".json")
        if FileManager.default.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    public func loadFromFile(url: URL){
        if let string = FileManager.default.readTextFile(url: url),let data : PlaceList = PlaceList.fromJSON(encoded: string){
            places = data
        }
    }
    
    public func cleanupFiles(){
        let fileURLs = FileManager.default.listAllURLs(dirURL: FileManager.mediaDirURL)
        var itemURLs = Array<URL>()
        var count = 0
        for item in places.fileItems{
            itemURLs.append(item.fileURL)
        }
        for url in fileURLs{
            if !itemURLs.contains(url){
                Log.debug("deleting local file \(url.lastPathComponent)")
                FileManager.default.deleteFile(url: url)
                count += 1
            }
        }
        if count > 0{
            Log.info("cleanup: deleted \(count) local unreferenced files")
        }
    }
    
}

