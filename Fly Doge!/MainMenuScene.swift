//
//  MainMenuScene.swift
//  Fly Doge!
//
//  Created by Anton Tran on 5/1/21.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene{
    
    var currentGameState = gameState.preGame
    
    
    
    
    override func didMove(to view: SKView) {
        
        
        
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)


        }
        
        
        
        
       
        
        let gameBy = SKLabelNode(fontNamed: "Minecraft")
        gameBy.text = "DCENTRAL Inc."
        gameBy.fontSize = 50
        gameBy.fontColor = SKColor.white
        gameBy.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.78)
        gameBy.zPosition = 1
        self.addChild(gameBy)
        
        let gameName1 = SKLabelNode(fontNamed: "Minecraft")
        gameName1.text = "Fly Doge!"
        gameName1.fontSize = 100
        gameName1.fontColor = SKColor.white
        gameName1.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameName1.zPosition = 1
        self.addChild(gameName1)
        
        let gameName2 = SKLabelNode(fontNamed: "Minecraft")
        gameName2.text = "To the Moon!"
        gameName2.fontSize = 150
        gameName2.fontColor = SKColor.white
        gameName2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.625)
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        let startGame = SKLabelNode(fontNamed: "Minecraft")
        startGame.text = "Start"
        startGame.fontSize = 75
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.3)
        startGame.zPosition = 1
        startGame.name = "startButton"
        self.addChild(startGame)
        
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            
            if  nodeITapped.name == "startButton" {
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        
        }
        
        
        
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 700.0
    
    override func update(_ currentTime: TimeInterval){
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background"){
            background, stop in

            if self.currentGameState == gameState.inGame || self.currentGameState == gameState.preGame{
            background.position.y -= amountToMoveBackground
            }

            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }


        }

        

    
    
    
    
    

}
