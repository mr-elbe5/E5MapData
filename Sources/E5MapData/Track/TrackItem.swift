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
        simplifyTrack()
    }
    
    @discardableResult
    public func addTrackpoint(from location: CLLocation){
        let tp = Trackpoint(location: location)
        if trackpoints.isEmpty{
            trackpoints.append(tp)
            startTime = tp.timestamp
            return
        }
        let previousTrackpoint = trackpoints.last!
        let timeDiff = previousTrackpoint.timestamp.distance(to: tp.timestamp)
        print (timeDiff)
        if timeDiff < Preferences.shared.trackpointInterval{
            return
        }
        let horizontalDiff = previousTrackpoint.coordinate.distance(to: tp.coordinate)
        if horizontalDiff < Preferences.shared.minHorizontalTrackpointDistance{
            return
        }
        let verticalDiff = previousTrackpoint.altitude - tp.altitude
        trackpoints.append(tp)
        distance += horizontalDiff
        if verticalDiff > 0{
            upDistance += verticalDiff
        }
        else if verticalDiff < 0{
            downDistance += -verticalDiff
        }
        endTime = tp.timestamp
    }
    
    public func simplifyTrack(){
        Log.info("simplifying track starting with \(trackpoints.count) trackpoints")
        var i = 0
        while i + 2 < trackpoints.count{
            if canDropMiddleTrackpoint(tp0: trackpoints[i], tp1: trackpoints[i+1], tp2: trackpoints[i+2]){
                trackpoints.remove(at: i+1)
            }
            else{
                i += 1
            }
        }
        Log.info("ending with \(trackpoints.count)")
    }
    
    public func canDropMiddleTrackpoint(tp0: Trackpoint, tp1: Trackpoint, tp2: Trackpoint) -> Bool{
        //calculate expected middle coordinated between outer coordinates by triangles
        let outerLatDiff = tp2.coordinate.latitude - tp0.coordinate.latitude
        let outerLonDiff = tp2.coordinate.longitude - tp0.coordinate.longitude
        var expectedLatitude = tp1.coordinate.latitude
        if outerLatDiff == 0{
            expectedLatitude = tp0.coordinate.latitude
        }
        else if outerLonDiff == 0{
            expectedLatitude = tp1.coordinate.latitude
        }
        else{
            let innerLonDiff = tp1.coordinate.longitude - tp0.coordinate.longitude
            expectedLatitude = outerLatDiff*(innerLonDiff/outerLonDiff) + tp0.coordinate.latitude
        }
        let expectedCoordinate = CLLocationCoordinate2D(latitude: expectedLatitude, longitude: tp1.coordinate.longitude)
        //check for middle coordinate being close to expected coordinate
        return tp1.coordinate.distance(to: expectedCoordinate) <= Preferences.shared.maxTrackpointInLineDeviation
    }
    
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

