/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

open class CoordinateRegion{
    
    public var minLatitude : CLLocationDegrees
    public var maxLatitude : CLLocationDegrees
    public var minLongitude : CLLocationDegrees
    public var maxLongitude : CLLocationDegrees
    
    public var center: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2, longitude: (minLongitude + maxLongitude)/2)
    }
    
    public var mapRect : CGRect{
        let topLeft = CGPoint(CLLocationCoordinate2D(latitude: maxLatitude, longitude: minLongitude))
        let bottomRight = CGPoint(CLLocationCoordinate2D(latitude: minLatitude, longitude: maxLongitude))
        return CGRect(origin: CGPoint(x: topLeft.x, y: topLeft.y), size: CGSize(width: bottomRight.x - topLeft.x, height: topLeft.y - bottomRight.y))
    }
    
    public init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D){
        maxLatitude = topLeft.latitude
        minLatitude = bottomRight.latitude
        minLongitude = topLeft.longitude
        maxLongitude = bottomRight.longitude
    }
    
    public init(minLatitude: CLLocationDegrees, maxLatitude: CLLocationDegrees, minLongitude: CLLocationDegrees, maxLongitude: CLLocationDegrees){
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    public func contains(coordinate: CLLocationCoordinate2D) -> Bool{
        coordinate.latitude >= minLatitude && coordinate.latitude <= maxLatitude && coordinate.longitude >= minLongitude && coordinate.longitude <= maxLongitude
    }
    
    open var string : String{
        "minLatitude = \(minLatitude), maxLatitude = \(maxLatitude), minLongitude = \(minLongitude), maxLongitude = \(maxLongitude)"
    }
    
}
