/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

open class PlacemarkService{
    
    public static var shared = PlacemarkService()
    
    private let geocoder = CLGeocoder()
    
    public func getPlacemark(for location: CLLocation, result: @escaping(CLPlacemark?) -> Void){
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil, let placemark =  placemarks?[0]{
                result(placemark)
            }
            else{
                result(nil)
            }
        })
    }
    
}

