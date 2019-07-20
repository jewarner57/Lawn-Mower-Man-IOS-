//
//  Grass.swift
//  Lawn Mower Man
//
//  Created by Jonathan Warner on 3/14/17.
//  Copyright © 2017 TeedethGaming. All rights reserved.
//

import Foundation
import SpriteKit

//class for each piece of grass, to test if grass is mowed or not easily
class grassClass: SKSpriteNode {
    
    var mowed:Bool = false
    //the mower is touching this grass particle, change its color
    func mowGrass() {
        
        mowed = true
        
    }
    //regrow the grass
    func grow() {
        
        mowed = false
        
    }
    //has the current tile been mowed
    func isMowed() -> Bool {
        
        return mowed
        
    }
    
}

var grassArray = [grassClass]()

//is player touching grass particles?
func collision(_ grass: grassClass) -> Bool {
    
    if(grass.position.x + grass.size.width/2 > player.position.x - player.size.width/2)
        
        && (grass.position.x - grass.size.width/2 < player.position.x + player.size.width/2
            
            && grass.position.y + grass.size.height/2 > player.position.y - player.size.height/2)
        
        && (grass.position.y - grass.size.height/2 < player.position.y + player.size.height/4) /*is grass touching player? bladeSize is used to make the mower blade size larger */ {
        
        return true
        
    }
    else {
        return false
    }
    
}
