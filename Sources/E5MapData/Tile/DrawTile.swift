/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import E5Data

public class DrawTileData{
    
    public var drawRect: CGRect
    public var tile: MapTile
    public var complete = false
    
    public init(drawRect: CGRect, tile: MapTile){
        self.drawRect = drawRect
        self.tile = tile
    }
    
    public func assertTileImage(){
        if tile.image == nil {
            TileProvider.shared.loadTileImage(tile: tile, template: Preferences.shared.urlTemplate){ success in
                if success{
                    self.complete = true
                }
            }
        }
        else{
            complete = true
        }
    }
    
    public func draw(){
        if let image = tile.image{
            image.draw(in: drawRect)
        }
    }
    
}

public typealias DrawTileList = Array<DrawTileData>

extension DrawTileList{
    
    public var complete: Bool{
        for drawTile in self{
            if !drawTile.complete{
                return false
            }
        }
        return true
    }
    
    public func assertDrawTileImages() -> Bool{
        for drawTile in self{
            drawTile.assertTileImage()
        }
        return complete
    }
    
    public func draw(){
        for drawTile in self{
            drawTile.draw()
        }
    }
    
}
