/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLPlacemark{
    
    public var locationString: String{
        "\(thoroughfare ?? "") \(subThoroughfare ?? "")\n\(postalCode ?? "") \(locality ?? "")\n\(country ?? "")"
    }
    
    public var asString: String{
        if let name = name{
            return name
        }
        return locationString
    }
    
}
