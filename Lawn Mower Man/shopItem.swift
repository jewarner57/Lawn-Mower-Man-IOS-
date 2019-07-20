//
//  shopItem.swift
//  Lawn Mower Man
//
//  Created by Jonathan Warner on 3/14/17.
//  Copyright © 2017 TeedethGaming. All rights reserved.
//

import Foundation
import SpriteKit

//class for all Items in the shop, so that they can each maintain unique prices
class shopItem: SKSpriteNode {
    
    var priceArray: [Int] = []
    var texturePrefix = "???"
    var atMax:Bool = false
    var upgradeLevel:Int = 0
    var lineUpPosition:Int = -1 //negative 1 prevents it from displaying until it is set by setLinePosition()
    
    //allows each shop item's texture to be easily refrenced, each texture will be identified by the prefix, then a number
    //(the current upgrade level)
    func addTexturePrefix(_ prefix:String) {
        
        texturePrefix = prefix
        
    }
    //triggered when a shop Icon is clicked. This buys the upgrade and changes the stat associated with it
    func upgradeAffect() {
        
        self.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.07), SKAction.fadeAlpha(to: 1, duration: 0.07)]))
        
        if(priceArray[upgradeLevel] <= score && priceArray[upgradeLevel] != -1) { //-1 means that the array has ended and that that is the max upgrade level
            print(priceArray[upgradeLevel])
            score -= priceArray[upgradeLevel]
            upgradeLevel+=1
            
            let texture = "\(texturePrefix) \(upgradeLevel)"
            self.texture = SKTexture(imageNamed: texture)
            
            
            //add the abilities of items bought in the shop, speed, blade size, etc into the if statement below
            if(texturePrefix == "speed") {
                speedUpgradeVar += 2
            }
            else if(texturePrefix == "mowed") {
                
                grassMowedPayAmount += 10
                
            }
            else if(texturePrefix == "blade") {
                
                player.size.width += 10
                player.size.height += 10
                playerSizeBox += 4
                
            }
            else if(texturePrefix == "active") {
                
                
                if(activeIncome == 8) {
                    activeIncome += 2
                }
                else  {
                    activeIncome += 1
                }
                
            }
            else if(texturePrefix == "passive") {
                
                if(passiveIncome < 6) {
                    passiveIncome += 1
                }
                else {
                    passiveIncome += 2
                }
                
            }
            else if(texturePrefix == "golden") {
                
                isGolden = true
                makeCoins = true
                
            }
            
        }
        else {
            print("Insufficient funds!")
        }
        
        
    }
    
    func getUpgradeLevel() -> Int {
        
        return upgradeLevel
        
    }
    //returns the shopItem's texture prefix
    func getTexturePrefix() -> String {
        return texturePrefix
    }
    
    //add another price to the array of prices
    func addPriceToArray(_ price:Int) {
        
        priceArray.append(price)
        
    }
    
    
    func reachedMax() {
        atMax = true
    }
    
    //has Upgrade been fully purchased?
    func isAtMax() -> Bool {
        return atMax
    }
    //set position in shop lineup
    func setLinePosition(_ num:Int) {
        lineUpPosition = num
    }
    //get icon's position in shop lineup
    func getLinePosition() -> Int {
        return lineUpPosition
    }
    
}

//hide the unwanted shop icons and show the correct one
func shopItemSlide() {
    for item in shopArray {
        if(shopItemNum % 5 == item.getLinePosition()) {
            item.position.x = -shopBackground.size.width/2 + speedUpgrade.size.width*0.8
            item.run(SKAction.fadeIn(withDuration: 0.25))
            
        }
        else if(!(item.texturePrefix == "golden")) {
            item.run(SKAction.fadeOut(withDuration: 0.25))
            item.position.x += 1000
            
        }
    }
}
