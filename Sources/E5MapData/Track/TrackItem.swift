/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation
import E5Data

open class TrackItem : PlaceItem{
    
    private enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case name
        case trackpoints
        case distance
        case upDistance
        case downDistance
        case note
    }
    
    public static var visibleTrack : TrackItem? = nil
    
    public var startTime : Date
    public var pauseTime : Date? = nil
    public var pauseLength : TimeInterval = 0
    public var endTime : Date
    public var name : String
    public var trackpoints : TrackpointList
    public var distance : CGFloat
    public var upDistance : CGFloat
    public var downDistance : CGFloat
    public var note : String
    
    override public var type : PlaceItemType{
        get{
            return .track
        }
    }
    
    public var duration : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: endTime) - pauseLength
    }
    
    public var durationUntilNow : TimeInterval{
        if let pauseTime = pauseTime{
            return startTime.distance(to: pauseTime) - pauseLength
        }
        return startTime.distance(to: Date.localDate) - pauseLength
    }
    
    public var startCoordinate: CLLocationCoordinate2D?{
        trackpoints.first?.coordinate
    }
    
    public var endCoordinate: CLLocationCoordinate2D?{
        trackpoints.last?.coordinate
    }
    
    override public init(){
        name = "trk"
        startTime = Date.localDate
        endTime = Date.localDate
        trackpoints = TrackpointList()
        distance = 0
        upDistance = 0
        downDistance = 0
        note = ""
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try values.decodeIfPresent(Date.self, forKey: .startTime) ?? Date.localDate
        endTime = try values.decodeIfPresent(Date.self, forKey: .endTime) ?? Date.localDate
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        trackpoints = try values.decodeIfPresent(TrackpointList.self, forKey: .trackpoints) ?? TrackpointList()
        distance = try values.decodeIfPresent(CGFloat.self, forKey: .distance) ?? 0
        upDistance = try values.decodeIfPresent(CGFloat.self, forKey: .upDistance) ?? 0
        downDistance = try values.decodeIfPresent(CGFloat.self, forKey: .downDistance) ?? 0
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        try super.init(from: decoder)
        creationDate = endTime
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(name, forKey: .name)
        try container.encode(trackpoints, forKey: .trackpoints)
        try container.encode(distance, forKey: .distance)
        try container.encode(upDistance, forKey: .upDistance)
        try container.encode(downDistance, forKey: .downDistance)
        try container.encode(note, forKey: .note)
    }
    
    public func pauseTracking(){
        pauseTime = Date.localDate
    }
    
    public func resumeTracking(){
        if let pauseTime = pauseTime{
            pauseLength += pauseTime.distance(to: Date.localDate)
            self.pauseTime = nil
        }
    }
    
    public func evaluateImportedTrackpoints(){
        distance = 0
        upDistance = 0
        downDistance = 0
        if let time = trackpoints.first?.timestamp{
            startTime = time
        }
        if let time = trackpoints.last?.timestamp{
            endTime = time
        }
        var last : Trackpoint? = nil
        for tp in trackpoints{
            if let last = last{
                distance += last.coordinate.distance(to: tp.coordinate)
                let vDist = tp.altitude - last.altitude
                if vDist > 0{
                    upDistance += vDist
                }
                else{
                    //invert negative
                    downDistance -= vDist
                }
            }
            last = tp
        }
        removeAllRedundant()
    }
    
    @discardableResult
    public func addLocation(_ location: CLLocation) -> Bool{
        let tp = Trackpoint(location: location)
        tp.checkValidity(maxUncertainty: Preferences.shared.maxHorizontalUncertainty)
        if !tp.horizontallyValid(maxUncertainty: Preferences.shared.maxHorizontalUncertainty){
            return false
        }
        if let previousTrackpoint = trackpoints.last{
            tp.updateDeltas(from: previousTrackpoint, minVerticalDistance: Preferences.shared.minVerticalTrackpointDistance)
            if tp.timeDiff < Preferences.shared.trackpointInterval{
                return false
            }
            if tp.horizontalDistance < Preferences.shared.minHorizontalTrackpointDistance && tp.verticalDistance == 0{
                return false
            }
            //debug("tp.alt = \(tp.altitude)")
            trackpoints.append(tp)
            //debug("vertDist = \(tp.verticalDistance)")
            if Preferences.shared.maxTrackpointInLineDeviation != 0 && removeRedundant(backFrom: trackpoints.count - 1){
                self.distance = trackpoints.distance
                upDistance = trackpoints.upDistance
                downDistance = trackpoints.downDistance
            }
            else{
                self.distance += tp.horizontalDistance
                if tp.verticalDistance > 0{
                    upDistance += tp.verticalDistance
                }
                else{
                    //invert negative
                    downDistance -= tp.verticalDistance
                }
            }
        }
        else{
            trackpoints.append(tp)
            startTime = tp.timestamp
        }
        endTime = tp.timestamp
        return true
    }
    
    public func removeRedundant(backFrom last: Int) -> Bool{
        if last < 2 || last >= trackpoints.count{
            return false
        }
        let tp0 = trackpoints[last - 2]
        let tp1 = trackpoints[last - 1]
        let tp2 = trackpoints[last]
        //calculate expected middle coordinated between outer coordinates by triangles
        let expectedLatitude = (tp2.coordinate.latitude - tp0.coordinate.latitude)/(tp2.coordinate.longitude - tp0.coordinate.longitude) * (tp1.coordinate.longitude - tp0.coordinate.longitude) + tp0.coordinate.latitude
        let expectedCoordinate = CLLocationCoordinate2D(latitude: expectedLatitude, longitude: tp1.coordinate.longitude)
        //check for middle coordinate being close to expected coordinate
        if tp1.coordinate.distance(to: expectedCoordinate) <= Preferences.shared.maxTrackpointInLineDeviation{
            trackpoints.remove(at: last - 1)
            tp2.updateDeltas(from: tp0, minVerticalDistance: Preferences.shared.minVerticalTrackpointDistance)
            return true
        }
        return false
    }
    
    public func removeAllRedundant(){
        Log.info("removing redundant trackpoints starting with \(trackpoints.count)")
        var i = 0
        while i + 2 < trackpoints.count{
            if !removeRedundant(backFrom: i){
                i += 1
            }
        }
        Log.info("removing redundant trackpoints ending with \(trackpoints.count)")
    }
    
}

public protocol TrackDelegate{
    func viewTrackItem(item: TrackItem)
    func showTrackItemOnMap(item: TrackItem)
}

public typealias TrackList = Array<TrackItem>

extension TrackList{
    
    public mutating func remove(_ track: TrackItem){
        for idx in 0..<self.count{
            if self[idx].equals(track){
                self.remove(at: idx)
                return
            }
        }
    }
    
    public mutating func sortByDate(){
        self.sort(by: { $0.startTime < $1.startTime})
    }
    
}

