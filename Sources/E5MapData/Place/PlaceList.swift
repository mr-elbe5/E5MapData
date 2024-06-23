/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import E5Data

public typealias PlaceList = Array<Place>

extension PlaceList{
    
    public mutating func remove(_ place: Place){
        removeAll(where: {
            $0.equals(place)
        })
    }
    
    public mutating func removePlaces(of list: PlaceList){
        for place in list{
            remove(place)
        }
    }
    
    public mutating func sortAll(){
        self.sort()
        for place in self{
            place.sortItems()
        }
    }
    
    public var filteredPlaces : PlaceList{
        switch AppState.shared.placeFilter{
        case .all: return self
        case .media:
            return self.filter({
                $0.hasMedia
            })
        case .track:
            return self.filter({
                $0.hasTrack
            })
        case .note:
            return self.filter({
                $0.hasNote
            })
        }
    }
    
    public var trackItems: Array<TrackItem>{
        get{
            var trackList = Array<TrackItem>()
            for place in self{
                trackList.append(contentsOf: place.tracks)
            }
            trackList.sortByDate()
            return trackList
        }
    }
    
    public var imageItems: Array<ImageItem>{
        get{
            var imageList = Array<ImageItem>()
            for place in self{
                imageList.append(contentsOf: place.images)
            }
            imageList.sort()
            return imageList
        }
    }
    
    public var fileItems: FileItemList{
        get{
            var fileList = FileItemList()
            for place in self{
                fileList.append(contentsOf: place.fileItems)
            }
            return fileList
        }
    }
    
    public func updateCreationDates(){
        for place in self{
            if !place.items.isEmpty{
                var creationDate = Date.localDate
                for item in place.items{
                    if item.creationDate < creationDate{
                        creationDate = item.creationDate
                    }
                }
                if creationDate < place.creationDate{
                    place.creationDate = creationDate
                }
            }
        }
    }
    
    public mutating func removeDuplicates(){
        for place in self{
            let duplicates = getDuplicates(of: place)
            if duplicates.count > 0{
                Log.warn("removing \(count) duplicates of id \(place.id)")
            }
            for duplicate in duplicates{
                self.remove(duplicate)
            }
            place.items.removeDuplicates()
        }
    }
    
    public func getDuplicates(of place: Place) -> PlaceList{
        var list = PlaceList()
        for otherPlace in self{
            if place != otherPlace, place.equals(otherPlace){
                list.append(otherPlace)
            }
        }
        return list
    }
    
}
