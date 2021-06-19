//
//  GameOverScene.swift
//  Fly Doge!
//
//  Created by Anton Tran on 5/1/21.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{

    let restartLabel = SKLabelNode(fontNamed: "Minecraft")
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
        
        
        
        let gameOverLabel = SKLabelNode(fontNamed: "Minecraft")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 150
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.75)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        
        let scoreLabel = SKLabelNode(fontNamed: "Minecraft")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 100
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.6)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
        let defaults = UserDefaults()
        var highScoreNum = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScoreNum{
            
            highScoreNum = gameScore
            defaults.set(highScoreNum, forKey: "highScoreSaved")
            
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "Minecraft")
        highScoreLabel.text = "High Score: \(highScoreNum)"
        highScoreLabel.fontSize = 100
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.5)
        self.addChild(highScoreLabel)
        
        
        restartLabel.text = "Play again"
        restartLabel.fontSize = 75
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(restartLabel)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
        
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch){
            
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
