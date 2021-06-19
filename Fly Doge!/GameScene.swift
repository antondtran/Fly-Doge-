//
//  GameScene.swift
//  Fly Doge!
//
//  Created by Anton Tran on 5/1/21.
//


import SpriteKit
import GameplayKit
import AVFoundation

var gameScore = 0

enum gameState{
    case preGame
    case inGame
    case afterGame

}

let url = Bundle.main.url(forResource: "explosion", withExtension: "wav")!
let player = try! AVAudioPlayer(contentsOf: url)

let url2 = Bundle.main.url(forResource: "wingame", withExtension: "wav")!
let player2 = try! AVAudioPlayer(contentsOf: url2)

let url3 = Bundle.main.url(forResource: "click", withExtension: "wav")!
let player3 = try! AVAudioPlayer(contentsOf: url3)

let url4 = Bundle.main.url(forResource: "speedup", withExtension: "mp3")!
let player4 = try! AVAudioPlayer(contentsOf: url4)






class GameScene: SKScene, SKPhysicsContactDelegate {

    var scoreLabel = SKLabelNode(fontNamed: "Minecraft")
    // setting spaceship image

    var gameStateIsInGame = true






    var currentGameState = gameState.preGame
    var levelNumber = 0


    let spaceship = SKSpriteNode(imageNamed: "ufo")
 
    let tapToStart = SKLabelNode(fontNamed: "Minecraft")

    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Spaceship : UInt32 = 0b1
        static let Meteor : UInt32 = 0b10
    }

    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }




    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    let maxAspectRatio: CGFloat
    let playableArea: CGRect

    override init(size: CGSize){

        maxAspectRatio = deviceHeight / deviceWidth
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width - playableWidth) / 2.0
        playableArea = CGRect(x: playableMargin, y: 0, width: playableWidth, height: size.height)

        super.init(size: size)
    }

    func drawPlayableArea(){
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableArea)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 8
        addChild(shape)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        gameScore = 0

        self.physicsWorld.contactDelegate = self

        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)


        }

        scoreLabel.text = "0"
        scoreLabel.fontSize = 90
        scoreLabel.fontColor = SKColor.red
        scoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)











        // Sizing and layering spaceship image.

        spaceship.setScale(1)
        spaceship.position = CGPoint(x: self.size.width/2, y: 0 - self.size.height)
        spaceship.zPosition = 1
        spaceship.physicsBody = SKPhysicsBody(rectangleOf: spaceship.size)
        spaceship.physicsBody!.affectedByGravity = false
        spaceship.physicsBody!.categoryBitMask = PhysicsCategories.Spaceship
        spaceship.physicsBody!.collisionBitMask = PhysicsCategories.None
        spaceship.physicsBody!.contactTestBitMask = PhysicsCategories.Meteor
        self.addChild(spaceship)



        tapToStart.text = "Tap to start"
        tapToStart.fontSize = 100
        tapToStart.fontColor = SKColor.green
        tapToStart.zPosition = 1
        tapToStart.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStart.alpha = 0
        self.addChild(tapToStart)

        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStart.run(fadeInAction)
        drawPlayableArea()




    }

    func addScore(){
        gameScore += 1
        scoreLabel.text = "\(gameScore)"
        if gameScore == 1000 || gameScore == 2000 || gameScore == 3000 ||  gameScore == 4000{
            startLevel()
        } else if gameScore == 5000{
            startLevel()
            player4.play()
        }else if gameScore == 6000 || gameScore == 7000 || gameScore == 8000 || gameScore == 9000 || gameScore == 9500{
            startLevel()
        } else if gameScore == 10000{
            runWinningScene()
            player2.play()
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

        if gameStateIsInGame && currentGameState == gameState.inGame{
            addScore()



            if gameScore == 5000{
                amountToMovePerSecond = 5000.0
            }




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



    func didBegin(_ contact: SKPhysicsContact){

        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }

        if body1.categoryBitMask == PhysicsCategories.Spaceship && body2.categoryBitMask == PhysicsCategories.Meteor{

            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }

            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }


            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            player.play()
            runGameOver()
        }

    }

    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)

        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()

        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }

    func spawnMeteor(){
        let randomXStart = random(min: playableArea.minX, max: playableArea.maxX )
        let  randomXEnd = random(min: playableArea.minX, max: playableArea.maxX )

        let  startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)

        let meteor = SKSpriteNode(imageNamed: "meteor")
        meteor.name = "Meteor"
        meteor.setScale(1)
        meteor.position = startPoint
        meteor.zPosition = 2
        meteor.physicsBody = SKPhysicsBody(rectangleOf: meteor.size)
        meteor.physicsBody!.affectedByGravity = false
        meteor.physicsBody!.categoryBitMask = PhysicsCategories.Meteor
        meteor.physicsBody!.collisionBitMask = PhysicsCategories.None
        meteor.physicsBody!.contactTestBitMask = PhysicsCategories.Spaceship
        self.addChild(meteor)

        let moveMeteor = SKAction.move(to: endPoint, duration: 1.5)
        let deleteMeteor = SKAction.removeFromParent()
        let meteorSequence = SKAction.sequence([moveMeteor, deleteMeteor])
        meteor.run(meteorSequence)

        if currentGameState == gameState.inGame{
            meteor.run(meteorSequence)
        }

        let rotateX = endPoint.x - startPoint.x
        let rotateY = endPoint.y - startPoint.y
        let amountToRotate = atan2(rotateY, rotateX)
        meteor.zRotation = amountToRotate
    }



    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)

    }

    func winningScene(){
        let sceneToMoveTo = WinningScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }

    func startLevel(){

        levelNumber += 1


        if self.action(forKey: "spawnMeteor") != nil{
            self.removeAction(forKey: "spawnMeteor")
        }

        var levelDuration = TimeInterval()


        switch levelNumber {
        case 1: levelDuration = 0.8
            print("Level 1")
        case 2: levelDuration = 0.7
            print("Level 2")
        case 3: levelDuration = 0.6
            print("Level 3")
        case 4: levelDuration = 0.5
            print("Level 4")
        case 5: levelDuration = 0.4
            print("Level 5")
        case 6: levelDuration = 0.3
            print("Level 6")
        case 7: levelDuration = 0.25
            print("Level 7")
        case 8: levelDuration = 0.23
            print("Level 8")
        case 9: levelDuration = 0.21
            print("Level 9")
        case 10: levelDuration = 0.19
            print("Level 10")
        case 11: levelDuration = 0.15
            print("Level MAX")
        default:
            levelDuration = 0.15
            print("Cannot find level info")
        }

        let spawn = SKAction.run(spawnMeteor)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawnMeteor")



    }
    func runGameOver(){
        currentGameState = gameState.afterGame

        self.removeAllActions()
        self.enumerateChildNodes(withName: "Meteor"){
            meteor, stop in

            meteor.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }

    func runWinningScene(){
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Meteor"){
            meteor, stop in

            meteor.removeAllActions()
        }
        let changeSceneAction = SKAction.run(winningScene)
        let changeSceneSequence = SKAction.sequence([changeSceneAction])
        self.run(changeSceneSequence)

    }





    func startGame(){
        currentGameState = gameState.inGame


        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStart.run(deleteSequence)

        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        spaceship.run(startGameSequence)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame{
            startGame()

        }

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for spaceshipTouch: AnyObject in touches{
            let pointOfTouch = spaceshipTouch.location(in: self)
            let previousPointOfTouch = spaceshipTouch.previousLocation(in: self)

            let amountDragged = pointOfTouch.x - previousPointOfTouch.x

            if currentGameState == gameState.inGame{
            spaceship.position.x += amountDragged
            }

            // Too far right

            if spaceship.position.x >= playableArea.maxX - spaceship.size.width / 2{
                spaceship.position.x = playableArea.maxX - spaceship.size.width / 2
            }

            // Too far left

            if spaceship.position.x <= playableArea.minX + spaceship.size.width / 2{
                spaceship.position.x = playableArea.minX  + spaceship.size.width / 2
            }
        }
    }



}
