/*
 E5MapData
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
            if let error = error{
                print(error)
                result(nil)
                return
            }
            if let placemark =  placemarks?[0]{
                print("got placemark")
                result(placemark)
            }
            else{
                print("no placemark")
                result(nil)
            }
        })
    }
    
}

