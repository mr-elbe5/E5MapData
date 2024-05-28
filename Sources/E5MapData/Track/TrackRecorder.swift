/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

open class TrackRecorder{
    
    public static var track : TrackItem? = nil
    public static var isRecording : Bool = false
    
    public static func startRecording(startLocation: CLLocation){
        if track == nil{
            track = TrackItem()
            track!.trackpoints.append(Trackpoint(location: startLocation))
        }
        isRecording = true
    }
    
    public static func updateTrack(with location: CLLocation) -> Bool{
        if let track = track{
            return track.addLocation(location)
        }
        return false
    }
    
    public static func pauseRecording(){
        if let track = track{
            track.pauseTracking()
            isRecording = false
        }
    }
    
    public static func resumeRecording(){
        if let track = track{
            track.resumeTracking()
            isRecording = true
        }
    }
    
    public static func stopRecording(){
        if track != nil{
            isRecording = false
            track = nil
        }
    }
    
}
