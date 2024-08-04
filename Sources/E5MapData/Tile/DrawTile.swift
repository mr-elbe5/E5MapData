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

class DrawTileData{
    
    var drawRect: CGRect
    var tile: MapTile
    var complete = false
    
    init(drawRect: CGRect, tile: MapTile){
        self.drawRect = drawRect
        self.tile = tile
    }
    
    func assertTileImage(){
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
    
    func draw(){
        if let image = tile.image{
            image.draw(in: drawRect)
        }
    }
    
}

typealias DrawTileList = Array<DrawTileData>

extension DrawTileList{
    
    var complete: Bool{
        for drawTile in self{
            if !drawTile.complete{
                return false
            }
        }
        return true
    }
    
    func assertDrawTileImages() -> Bool{
        for drawTile in self{
            drawTile.assertTileImage()
        }
        return complete
    }
    
    func draw(){
        for drawTile in self{
            drawTile.draw()
        }
    }
    
}
