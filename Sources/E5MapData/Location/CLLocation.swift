/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLLocation{
    
    public var string: String{
        "lat: \(coordinate.latitude), lon: \(coordinate.longitude), speed: \(speed), course: \(course), time: \(timestamp.timestampString())"
    }
    
    public var speedUncertaintyFactor: Double{
        speedAccuracy < 0 ? -1 : speedAccuracy / speed
    }
    
    public var horizontalAccuracyValid : Bool{
        horizontalAccuracy >= 0 && horizontalAccuracy <= Preferences.shared.maxHorizontalUncertainty
    }
    
    public var speedAccuracyValid : Bool{
        speedAccuracy >= 0 && speedUncertaintyFactor <= Preferences.shared.maxSpeedUncertaintyFactor
    }
    
}
