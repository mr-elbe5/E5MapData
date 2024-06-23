/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

open class TrackRecorder{
    
    public static var track : TrackItem? = nil
    public static var isRecording : Bool = false
    
    public static func startRecording(){
        if track == nil{
            track = TrackItem()
        }
        isRecording = true
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
