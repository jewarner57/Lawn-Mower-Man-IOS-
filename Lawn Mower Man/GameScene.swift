//
//  GameScene.swift
//  Lawn Mower Man
//
//  Created by Jonathan Warner on 8/15/16.
//  Copyright (c) 2016 TeedethGaming. All rights reserved.
//


//add a level system so that you cant buy certain upgrades until a certain level
//add a grass bag that has to be emptied
//add different lawns to mow that are unlocked as the player progresses (with obstacles such as a road the mower has to cross to mow the whole lawn)
//sticks of course
//a better way to get rid of sticks (wood chipper)
//implement scrolling map
//add a save function
//add sounds
//customizeable mower

import SpriteKit


let player = SKSpriteNode(imageNamed: "player2")

//shop vars
let shopBackground = SKSpriteNode(imageNamed: "shopBackground")
let shopButton = SKSpriteNode(imageNamed: "shop")
let rightNav = SKSpriteNode(imageNamed: "shopArrowRight")
let leftNav = SKSpriteNode(imageNamed: "shopArrowLeft")
var shopArray: [shopItem] = []
var shopItemNum = 10
let speedUpgrade = shopItem(imageNamed: "speed 0")

let shopItemLbl = SKLabelNode(fontNamed:"Menlo")
//let shopItemLbl2 = SKLabelNode(fontNamed:"Menlo")
let itemDescriptionArray: [String] = ["Outrun grass", "Charge more for maimed lawns", "Grass will tremble at your monstrous size", "Get paid just for moving", "Get paid for simply being there"]

//has the golden mower upgrade been purchased
var isGolden = false
var makeCoins = false
var coinArray: [SKSpriteNode] = []
//upgrade vars
var speedUpgradeVar:CGFloat = 10
var grassMowedPayAmount = 50 //amount payed after mowing lawn completely
var activeIncome = 1
var passiveIncome = 0
var passiveHoldVar = passiveIncome
//movement vars
var touchX:CGFloat = 0
var touchY:CGFloat = 0
var playerXSpeed:CGFloat = 0
var playerYSpeed:CGFloat = 0

var mowerActive = false
var playerSizeBox = 42 //player's starting size

//lawn vars
var lawnMowed = false
var altCount = 0

var totalGrassMowed = 0 // total amount to be mowed is around 5,000 some?
//is shop open
var shopOpen:Bool = false

//score vars
var score = 0

let scoreLbl = SKLabelNode(fontNamed:"Menlo")

class GameScene: SKScene {
    
    func itemDescChange() {
        shopItemLbl.text = itemDescriptionArray[shopItemNum % 5]
        
        if(shopItemNum % 5 == 2) {
            shopItemLbl.fontSize = 23
        }
        else {
            shopItemLbl.fontSize = 30
        }
    }
    
    
    func shopItemClick(_ Item:shopItem) {
        
        print("Acted upon")
        Item.upgradeAffect()
        
        
    }
    
    func createCoin() {
        if(isGolden == true && makeCoins == true) {
            let coin = SKSpriteNode(imageNamed: "goldenCoin")
            coin.setScale(0.1)
            coin.position.x = CGFloat(arc4random_uniform(UInt32(self.size.width - coin.size.width * 2)) + UInt32(coin.size.width))
            coin.position.y = CGFloat(arc4random_uniform(UInt32(self.size.height - coin.size.height - 130)) + UInt32(coin.size.height + 130))
            coin.zPosition = 4
            if(coin.position.y < self.size.height - coin.size.height*2) {
                
                coinArray.append(coin)
                self.addChild(coin)
                
            }
        }
    }
    
    //slide out the shop pannel
    func openShop() {
        
        shopBackground.run(SKAction.sequence([SKAction.moveTo(x: self.size.width/2, duration: 1), SKAction.fadeIn(withDuration: 0.3)]))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
    
            self.itemDescChange()
            shopItemLbl.isHidden = false;
            shopOpen = true
            
    })
        
        
        leftNav.isHidden = false
        rightNav.isHidden = false
        
        leftNav.alpha = 0.7
        rightNav.alpha = 0.7
        
        rightNav.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeOut(withDuration: 1)]))
        leftNav.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeOut(withDuration: 1)]))
        
    }
    //slide in the shop pannel
    func closeShop() {
        
        
        shopBackground.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.3), SKAction.moveTo(x: self.size.width + shopBackground.size.width, duration: 1)]))
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            shopOpen = false
        })
        
        shopItemLbl.isHidden = true;
        
        leftNav.isHidden = true
        rightNav.isHidden = true
        
        
    }
    
    func createLawn() {
        
        
        
        for j in 0...49 {
            for i in 0...101 {
                let grass = grassClass(imageNamed: "unmowedTile")
                grass.size.height = (self.size.height/75)
                grass.size.width = (self.size.width/100)
                grass.position.y = CGFloat(j * Int(self.size.height/75))+(grass.size.height/2)+(self.size.height/75*17)
                
                grass.zPosition = 1
                
                grass.position.x = CGFloat(i * Int(self.size.width/100))+(grass.size.width/2)+2
                self.addChild(grass)
                
                grassArray.append(grass)
            }
        }
        
        scoreLbl.text = "0"
        scoreLbl.fontColor = UIColor.green
        scoreLbl.fontSize = 45
        scoreLbl.zPosition = 99
        scoreLbl.position.y = 116
        self.addChild(scoreLbl)
        
    }
    
    func tick() {
        
        let mowedAmnt = totalGrassMowed
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            
        score += passiveIncome
            
            if(((playerXSpeed > 0 || playerXSpeed < 0) || (playerYSpeed < 0 || playerYSpeed > 0)) && mowedAmnt < self.grassChange()) {
            
                score += activeIncome
                mowerActive = true
            
            }
            else {
                
                mowerActive = false
                
            }
        })
        
        
    }
    
    
    func grassChange() -> Int {
        
        return totalGrassMowed
        
    }
    
    func timerTrigger() {
        
        //create grass particles
            if(playerYSpeed == 0 && mowerActive == true) {

                let grassParticle = SKSpriteNode()
                
                if(!isGolden) {
                    grassParticle.texture = SKTexture(imageNamed: "grassParticle")
                }
                else {
                    grassParticle.texture = SKTexture(imageNamed: "goldenGrassParticle")
                }
                grassParticle.size.width = 5
                grassParticle.size.height = 5
                grassParticle.zPosition = 3
                grassParticle.position.x = player.position.x
                grassParticle.position.y = player.position.y - player.size.height/2
                grassParticle.physicsBody = SKPhysicsBody(rectangleOf: grassParticle.size)
                grassParticle.physicsBody?.affectedByGravity = false
                
                self.addChild(grassParticle)
                
                let randomValue = (drand48()*10)+20
                
                grassParticle.run(SKAction.sequence([SKAction.moveBy(x: -playerXSpeed, y: CGFloat(randomValue), duration: 0.2), SKAction.moveBy(x: -playerXSpeed, y: CGFloat(-randomValue), duration: 0.1),SKAction.wait(forDuration: 1), SKAction.removeFromParent()]))
                
            }
            
        
        
        player.run(SKAction.moveBy(x: playerXSpeed, y: 0, duration: 0.1))
        
        if((player.position.y - CGFloat(playerSizeBox) > 190 || playerYSpeed > 0) && (player.position.y + CGFloat(playerSizeBox) < self.size.height-50 || playerYSpeed < 0)) {
            
            player.run(SKAction.moveBy(x: 0, y: playerYSpeed, duration: 0.1))
            
        }
        
        if(player.position.x < 0 - player.size.width+2) {
            
            player.position.x = self.size.width+player.size.width/2
            
        }
        else if(player.position.x > self.size.width + player.size.width+2) {
            
            player.position.x = -player.size.width/2
            
        }
    }
    
    // DID MOVE TO VIEW
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        shopBackground.size.width = self.size.width
        shopBackground.size.height = self.size.height-self.size.height/2.8
        shopBackground.position.y = self.size.height / 2 + self.size.height/17
        shopBackground.position.x = self.size.width + shopBackground.size.width
        shopBackground.zPosition = 4
        shopBackground.alpha = 0.3
        
        
        
        //create shop upgrade navigation buttons
        rightNav.size.height = shopBackground.size.height
        rightNav.size.width = 60
        rightNav.position.x = shopBackground.size.width/2 - rightNav.size.width/2
        rightNav.position.y = 0
        rightNav.zPosition = 6
        rightNav.alpha = 0.7
        //rightNav.isHidden = true
        shopBackground.addChild(rightNav)
        
        
        leftNav.size.height = shopBackground.size.height
        leftNav.size.width = 60
        leftNav.position.x = -shopBackground.size.width/2 + leftNav.size.width/2
        leftNav.position.y = 0
        leftNav.zPosition = 6
        leftNav.alpha = 0.7
        //leftNav.isHidden = true
        shopBackground.addChild(leftNav)
        
        
        //create the speed upgrade shop button
        speedUpgrade.setScale(1.25)
        speedUpgrade.position.x = -shopBackground.size.width/2 + speedUpgrade.size.width*0.8
        speedUpgrade.position.y = shopBackground.size.height/5
        speedUpgrade.zPosition = 5
        speedUpgrade.addTexturePrefix("speed")
        speedUpgrade.setLinePosition(0)
        
        //add prices to the object's array
        speedUpgrade.addPriceToArray(50)
        speedUpgrade.addPriceToArray(100)
        speedUpgrade.addPriceToArray(400)
        speedUpgrade.addPriceToArray(925)
        speedUpgrade.addPriceToArray(1575)
        speedUpgrade.addPriceToArray(2195)
        speedUpgrade.addPriceToArray(3500)
        speedUpgrade.addPriceToArray(5000)
        speedUpgrade.addPriceToArray(-1)
        
        //create the mowedUpgrade shop button
        let mowedUpgrade = shopItem(imageNamed: "mowed 0")
        mowedUpgrade.setScale(1.25)
        mowedUpgrade.position.x = -shopBackground.size.width/2 + speedUpgrade.size.width*0.8//mowedUpgrade.position.x = speedUpgrade.position.x + mowedUpgrade.size.width*1.2
        mowedUpgrade.position.y = shopBackground.size.height/5
        mowedUpgrade.zPosition = 5
        mowedUpgrade.addTexturePrefix("mowed")
        mowedUpgrade.setLinePosition(1)
        
        //add prices to the objects array
        mowedUpgrade.addPriceToArray(12)
        mowedUpgrade.addPriceToArray(17)
        mowedUpgrade.addPriceToArray(22)
        mowedUpgrade.addPriceToArray(27)
        mowedUpgrade.addPriceToArray(32)
        mowedUpgrade.addPriceToArray(37)
        mowedUpgrade.addPriceToArray(42)
        mowedUpgrade.addPriceToArray(50)
        mowedUpgrade.addPriceToArray(-1)
        //create the blade upgrade shop button
        let bladeUpgrade = shopItem(imageNamed: "blade 0")
        bladeUpgrade.setScale(1.25)
        bladeUpgrade.position.x = -shopBackground.size.width/2 + speedUpgrade.size.width*0.8//bladeUpgrade.position.x = mowedUpgrade.position.x + bladeUpgrade.size.width*1.2
        
        bladeUpgrade.position.y = shopBackground.size.height/5
        bladeUpgrade.zPosition = 5
        bladeUpgrade.addTexturePrefix("blade")
        bladeUpgrade.setLinePosition(2)
        
        //add the prices to the objects array
        bladeUpgrade.addPriceToArray(12)
        bladeUpgrade.addPriceToArray(50)
        bladeUpgrade.addPriceToArray(175)
        bladeUpgrade.addPriceToArray(345)
        bladeUpgrade.addPriceToArray(589)
        bladeUpgrade.addPriceToArray(698)
        bladeUpgrade.addPriceToArray(879)
        bladeUpgrade.addPriceToArray(1100)
        bladeUpgrade.addPriceToArray(-1)

        //create active money per second upgrade shop icon
        let activeUpgrade = shopItem(imageNamed: "active 0")
        activeUpgrade.setScale(1.25)
        activeUpgrade.position.x = -shopBackground.size.width/2 + speedUpgrade.size.width*0.8//activeUpgrade.position.x = bladeUpgrade.position.x + activeUpgrade.size.width*1.2
        
        activeUpgrade.position.y = shopBackground.size.height/5
        activeUpgrade.zPosition = 5
        activeUpgrade.addTexturePrefix("active")
        activeUpgrade.setLinePosition(3)
        
        //add the prices to the objects array
        activeUpgrade.addPriceToArray(80)
        activeUpgrade.addPriceToArray(175)
        activeUpgrade.addPriceToArray(300)
        activeUpgrade.addPriceToArray(500)
        activeUpgrade.addPriceToArray(785)
        activeUpgrade.addPriceToArray(1500)
        activeUpgrade.addPriceToArray(2850)
        activeUpgrade.addPriceToArray(4020)
        activeUpgrade.addPriceToArray(-1)
        
        //create passive money per second upgrade shop icon
        let passiveUpgrade = shopItem(imageNamed: "passive 0")
        passiveUpgrade.setScale(1.25)
        passiveUpgrade.position.x = -shopBackground.size.width/2 + speedUpgrade.size.width*0.8//passiveUpgrade.position.x = activeUpgrade.position.x + passiveUpgrade.size.width*1.2
        
        passiveUpgrade.position.y = shopBackground.size.height/5
        passiveUpgrade.zPosition = 5
        passiveUpgrade.addTexturePrefix("passive")
        passiveUpgrade.setLinePosition(4)
        
        //add the prices to the objects array
        passiveUpgrade.addPriceToArray(70)
        passiveUpgrade.addPriceToArray(180)
        passiveUpgrade.addPriceToArray(300)
        passiveUpgrade.addPriceToArray(530)
        passiveUpgrade.addPriceToArray(709)
        passiveUpgrade.addPriceToArray(1010)
        passiveUpgrade.addPriceToArray(1327)
        passiveUpgrade.addPriceToArray(1979)
        passiveUpgrade.addPriceToArray(-1)
        
        
        //create the golden mower upgrade
        let goldenMower = shopItem(imageNamed: "golden 0")
        goldenMower.position.x = -shopBackground.size.width/2 + speedUpgrade.size.width*0.8
        goldenMower.position.y = -shopBackground.size.height/4
        goldenMower.zPosition = 5
        goldenMower.addTexturePrefix("golden")
        goldenMower.setScale(1.25)
        
        //add the price to the array
        goldenMower.addPriceToArray(9999)
        goldenMower.addPriceToArray(-1)
        
        //add the shop icons to the for the loop to check if the button is being pressed
        
        shopArray.append(passiveUpgrade)
        shopArray.append(activeUpgrade)
        shopArray.append(bladeUpgrade)
        shopArray.append(speedUpgrade)
        shopArray.append(mowedUpgrade)
        shopArray.append(goldenMower)
        
        //add the shop icons to the parent
        shopBackground.addChild(goldenMower)
        shopBackground.addChild(passiveUpgrade)
        shopBackground.addChild(activeUpgrade)
        shopBackground.addChild(speedUpgrade)
        shopBackground.addChild(mowedUpgrade)
        shopBackground.addChild(bladeUpgrade)
        
        self.addChild(shopBackground)
        
        self.scene?.backgroundColor = SKColor(colorLiteralRed: 0.18, green: 0.35, blue: 0.18, alpha: 1)
        
        createLawn()
        
        let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.timerTrigger), userInfo: nil, repeats: true)
        
        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.tick), userInfo: nil, repeats: true)
        //create coins once the golden mower has been bought
        let _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(GameScene.createCoin), userInfo: nil, repeats: true)
        
        //create the mower
        player.setScale(0.2)
        player.position = CGPoint(x: player.size.width/2, y: self.size.height - 140)
        player.zPosition = 2
        
        self.addChild(player)
        
        //create the shop open button
        shopButton.position.x = self.size.width - 60
        shopButton.position.y = 135
        shopButton.setScale(0.21)
        shopButton.zPosition = 4
        
        self.addChild(shopButton)
        
        shopItemSlide()
        
        //show the shop item description
        shopItemLbl.text = "Powerup Description"
        shopItemLbl.position.y = self.size.height/1.5
        shopItemLbl.position.x = self.size.width/2
        shopItemLbl.fontColor = UIColor.green
        shopItemLbl.zPosition = 99
        shopItemLbl.isHidden = true
        
        self.addChild(shopItemLbl)
        
        //shopItemLbl2.text = "Powerup Description"
        //shopItemLbl2.position.y = self.size.height/2 - 1
        //shopItemLbl2.position.x = self.size.width/2 - 1
        //shopItemLbl2.fontColor = UIColor.black
        //shopItemLbl2.zPosition = 98
        //shopItemLbl2.isHidden = false
        
        //self.addChild(shopItemLbl2)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            touchX = location.x
            touchY = location.y
            
            if(shopButton.contains(location)) {
                if(!shopOpen)
                {
                    openShop()
                }
                else
                {
                    closeShop()
                }
            }
            
            if(shopOpen) {
            for shopIcon in shopArray {
                
                    if(shopIcon.contains(CGPoint(x: location.x - self.size.width/2, y: location.y - shopBackground.position.y))) {
                    
                        shopItemClick(shopIcon)
                        print("RecievedClick")
                    
                    }
                
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let endTouchX = location.x
            let endTouchY = location.y
            
            if (endTouchX > touchX && Int32(endTouchX - touchX) > abs(Int32(endTouchY-touchY))) {
                playerXSpeed = speedUpgradeVar
                playerYSpeed = 0
                //has the golden upgrade been purchased? If yes then change skin to golden skin
                if(!isGolden) {
                    player.texture  = SKTexture(imageNamed: "player2")
                }
                else  {
                    player.texture = SKTexture(imageNamed: "goldenMowerSkinRight")
                }
            }
            else if (endTouchX < touchX && Int32(touchX - endTouchX) > abs(Int32(endTouchY-touchY))) {
                playerXSpeed = -speedUpgradeVar
                playerYSpeed = 0
                //has the golden upgrade been purchased? If yes then change skin to golden skin
                if(!isGolden) {
                    player.texture  = SKTexture(imageNamed: "player")
                }
                else  {
                    player.texture = SKTexture(imageNamed: "goldenMowerSkinLeft")
                }

            }
            else if (endTouchY < touchY) {
                playerYSpeed = -(speedUpgradeVar - speedUpgradeVar/4)
                playerXSpeed = 0

            }
            else if (endTouchY > touchY) {
                playerYSpeed = speedUpgradeVar - speedUpgradeVar/4
                playerXSpeed = 0
            }
            else {
                playerYSpeed = 0
                playerXSpeed = 0
            }
            
            if(location.x > self.size.width-50 && location.y > 200 && shopOpen) {
                shopItemNum += 1
                shopItemSlide()
                itemDescChange()
                
                rightNav.alpha = 0.7
                rightNav.run(SKAction.fadeOut(withDuration: 0.5))
            }
            else if(location.x < 50 && location.y > 200 && shopOpen) {
                shopItemNum -= 1
                shopItemSlide()
                itemDescChange()
                
                leftNav.alpha = 0.7
                leftNav.run(SKAction.fadeOut(withDuration: 0.5))
            }
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        //keep the player from leaving the screen on the y axis
        
        for coin in coinArray {
            if(coin.position.x + coin.size.width/2 > player.position.x - player.size.width/2)
                
                && (coin.position.x - coin.size.width/2 < player.position.x + player.size.width/2
                    
                    && coin.position.y + coin.size.height/2 > player.position.y - player.size.height/2)
                
                && (coin.position.y - coin.size.height/2 < player.position.y + player.size.height/4) {
                
                coin.removeFromParent()
                
            }
        }
        
        
        scoreLbl.text = String(format: "$%i", score)
        scoreLbl.position.x = 15 +  scoreLbl.frame.width/2
        
        if(altCount == 0) {
            player.run(SKAction.moveBy(x: 0, y: 1.5, duration: 0))
            altCount = 1
        }
        else if(altCount == 1 && playerYSpeed == 0) {
            altCount = 0
            player.run(SKAction.moveBy(x: 0, y: -1.5, duration: 0))
        }
        
        
        for grass in grassArray {
            
            if(collision(grass) && !grass.isMowed()) {
                
                grass.texture = SKTexture(imageNamed: "mowedTile")
                grass.mowGrass()
                
                totalGrassMowed += 1
                
            }
            
        }
        
        if(totalGrassMowed > 5099) {
            
            totalGrassMowed = 0
            score += grassMowedPayAmount
            
            
            for grass in grassArray {
                
                grass.texture = SKTexture(imageNamed: "unmowedTile")
                grass.grow()
                
            }
            
        }
    }
}
