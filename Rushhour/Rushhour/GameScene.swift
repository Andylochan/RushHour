//
//  GameScene.swift
//  Rushhour
//
//  Created by Andy Lochan on 5/1/19.
//  Copyright © 2019 Andy Lochan. All rights reserved.
//  Github Version


//README
// All images used throughout the app were created from scratch in Sketch, including the app logo. Ill include a screenshot of my Sketch file in the report.
// The music files are from freesound.org
// I came up with the name RushHour from my observations of people's driving habits here in New York, especially on the belt and cross island pkwy.
// Upon first click, the aspect ratio for the game will fix itself. For some reason the aspect ratio will not start correctly from the start, so I set a flag from myVars in viewController that causes the game to reload intially to fix this issue.
// My personal highest score was 81 points <<<<<<<<


import SpriteKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var backgroundMusic: SKAudioNode!
    
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var gameState = GameState.showingLogo
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        //init func calls
        createPlayer()
        createBackground()
        createScore()
        createLogos()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.0) //Gravity
        physicsWorld.contactDelegate = self
        
        //main game music loop // Track 1: "race-track"  // Track 2: "tranceMusic"
        if let musicURL = Bundle.main.url(forResource: "race-track", withExtension: "wav") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //INIT sets aspectfill ratio from viewcontroller
        if MyVar.Startflag == 0 {
            let scene = GameScene(fileNamed: "GameScene")!
            let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
            self.view?.presentScene(scene, transition: transition)
            MyVar.Startflag += 1;
        }
        
        switch gameState {
        case .showingLogo:
            gameState = .playing //change game state upon first click
            
            let sound = SKAction.playSoundFileNamed("startbutton.wav", waitForCompletion: false)
            run(sound)
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.startCar()
                self.startTruck()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)
            
        case .playing:
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
            
        case .dead:
            let scene = GameScene(fileNamed: "GameScene")!
            let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
            self.view?.presentScene(scene, transition: transition)
            
            let sound = SKAction.playSoundFileNamed("ignition.mp3", waitForCompletion: false)
            run(sound)
        }
    }
    
    //Creates player car
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "C1V2") //Car 1 image
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10 //Set the player in front of other objects in view
        player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75) //set init start placement
        //player.position = CGPoint(x: 150, y: 350)
        
        addChild(player)
      
        //MARK: - IOS 13 BUG - Issue filed -> Sometimes will not create physicsBody
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())

        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        player.physicsBody?.collisionBitMask = 0
        
        let frame2 = SKTexture(imageNamed: "C2V2") //Car 2 image
        let frame3 = SKTexture(imageNamed: "C3V2") //Car 3 image
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01) //0.01 //Loop through car 1 2 3 images every 0.01 seconds
        let runForever = SKAction.repeatForever(animation) //run the loop forever
        
        player.run(runForever)
    }
    
    //Controls player movement by screen tap, always running
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        for touch in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
            player.position.y = location.y
        }
    }
    
    //Creates parallax scrolling background effect
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "RoadXR2") //Road image
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
            
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 0.80) //Refresh the image ever 0.8 sec and move the image left on the x axis
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0 , duration: 0)
            //let moveLeft = SKAction.moveBy(x: 0, y: -backgroundTexture.size().width, duration: 20) //Swaped x and y to go up
            //let moveReset = SKAction.moveBy(x: 0, y: backgroundTexture.size().width, duration: 0) //Swaped x and y to go up
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    //Score label on header
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack") //Font type
        scoreLabel.fontSize = 24 //Font size
        
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 55) //Set right under the iphone Xr notch
        scoreLabel.text = "SCORE: 0" //Init
        scoreLabel.fontColor = UIColor.black //Font Color
        
        addChild(scoreLabel)
    }
    
    //Rushhour logo and State Engine button
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "RushHourLogo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY) //Middle of frame
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "GameOver")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY) //Middle of frame
        gameOver.alpha = 0
        addChild(gameOver)
    }
    
    //Notes
    //Create multiple func createTruck(), createCar() , then randomize the xPosition and yPosition for each,
    //add to self.create____ in StartCar()
    //create multiple sequences with create2/wait2 etc
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func CreateCar() {
        // 1 Set blue car image
        let carTexture = SKTexture(imageNamed: "E1")
        
        let topCar = SKSpriteNode(texture: carTexture)
        topCar.physicsBody = SKPhysicsBody(texture: carTexture, size: carTexture.size())
        topCar.physicsBody?.isDynamic = false

        
        let bottomCar = SKSpriteNode(texture: carTexture)
        bottomCar.physicsBody = SKPhysicsBody(texture: carTexture, size: carTexture.size())
        bottomCar.physicsBody?.isDynamic = false
        
        topCar.zPosition = -21 //Position behind trucks
        bottomCar.zPosition = -21 //Position behind trucks
        
        
        // 2 Point collision zone for score
        let carCollision = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 32, height: 140))
        carCollision.physicsBody = SKPhysicsBody(rectangleOf: carCollision.size)
        carCollision.physicsBody?.isDynamic = false
        carCollision.name = "scoreDetectCar"
        
        carCollision.zPosition = -21 //Position behind trucks
        
        addChild(topCar)
        addChild(bottomCar)
        addChild(carCollision)
        
        
        // 3 Car spawn position
        let xPosition = frame.width + topCar.frame.width
        
        let yPosition = CGFloat.random(in: 200...700)
        //let yPosition = CGFloat(300) //Debug
        
        
        // affects the width of the gap between cars
        // smaller = harder
        let carDistance: CGFloat = 100 // 80
        
        // 4
        topCar.position = CGPoint(x: xPosition, y: yPosition + topCar.size.height + carDistance)
        bottomCar.position = CGPoint(x: xPosition, y: yPosition - carDistance) //same x pos
        
        carCollision.position = CGPoint(x: xPosition + (carCollision.size.width * 2), y: yPosition + 25)
        
        let endPosition = frame.width + (topCar.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 5)//5 Controls speed
        //let moveAction = SKAction.moveBy(x: 0, y: -endPosition, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topCar.run(moveSequence)
        bottomCar.run(moveSequence)
        carCollision.run(moveSequence)
    }
    
    //call CreateCar forever
    func startCar() {
        let create = SKAction.run { [unowned self] in
            self.CreateCar()
        }
        
        let wait = SKAction.wait(forDuration: 3.2) //Create a new car ever 3.2 sec, after 3 rotations a truck will spawn too
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //Similiar function for trucks, but harder (smaller gaps) , trucks increment score by 5
    func createTruck() {
        // 1 Set truck image
        let truckTexture = SKTexture(imageNamed: "T1") //Truck image vector
        
        let topTruck = SKSpriteNode(texture: truckTexture)
        topTruck.physicsBody = SKPhysicsBody(texture: truckTexture, size: truckTexture.size())
        topTruck.physicsBody?.isDynamic = false
        
        
        let bottomTruck = SKSpriteNode(texture: truckTexture)
        bottomTruck.physicsBody = SKPhysicsBody(texture: truckTexture, size: truckTexture.size())
        bottomTruck.physicsBody?.isDynamic = false
        
        topTruck.zPosition = -20
        bottomTruck.zPosition = -20
        
        
        // 2 Point collision zones, for score
        let TruckCollision = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 32, height: 130))
        TruckCollision.physicsBody = SKPhysicsBody(rectangleOf: TruckCollision.size)
        TruckCollision.physicsBody?.isDynamic = false
        TruckCollision.name = "scoreDetectTruck"
        
        addChild(topTruck)
        addChild(bottomTruck)
        addChild(TruckCollision)
        
        
        // 3 Truck spawn positions
        let xPosition = frame.width + topTruck.frame.width
        
        let yPosition = CGFloat.random(in: 200...700)
        //let yPosition = CGFloat(300)
        
        
        // affects the width of the gap between trucks
        // smaller = harder
        // Slightly smaller gap versus cars, harder since its worth 5 points
        let TruckDistance: CGFloat = 70
        
        // 4
        topTruck.position = CGPoint(x: xPosition, y: yPosition + topTruck.size.height + TruckDistance)
        bottomTruck.position = CGPoint(x: xPosition, y: yPosition - TruckDistance) //same x pos

        TruckCollision.position = CGPoint(x: xPosition + (TruckCollision.size.width * 2), y: yPosition + 90)
        
        let endPosition = frame.width + (topTruck.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 7.7)//7 Controls speed
        //let moveAction = SKAction.moveBy(x: 0, y: -endPosition, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topTruck.run(moveSequence)
        bottomTruck.run(moveSequence)
        TruckCollision.run(moveSequence)
    }
    
    //calls createTruck forever, every 10 seconds
    func startTruck() {
        let create = SKAction.run { [unowned self] in
            self.createTruck()
        }
        
        let wait = SKAction.wait(forDuration: 10)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard player != nil else { return }
    }
    
    //Collision detection Case 1-4
    func didBegin(_ contact: SKPhysicsContact) {
   
        //Case 1 (Cars)
        //Check if player made it through car gap, increment score by 1 and play sound
        if contact.bodyA.node?.name == "scoreDetectCar" || contact.bodyB.node?.name == "scoreDetectCar" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            let sound = SKAction.playSoundFileNamed("coins-1.wav", waitForCompletion: false)
            run(sound)
            
            score += 1 //Going through cars increments score by 1 point
            
            return
        }
        
        //Case 2 (Trucks)
        //Check if player made it through truck gap, increment score by 5 and play sound
        if contact.bodyA.node?.name == "scoreDetectTruck" || contact.bodyB.node?.name == "scoreDetectTruck" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            let sound = SKAction.playSoundFileNamed("truckBonus.wav", waitForCompletion: false) //Trucks also have a different bonus sound
            run(sound)
            
            score += 5 //Trucks get 5 points since they are harder to get through
            
            return
        }
        
        //Case 3 (Reset)
        //default
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else {
            return
        }
        
        //Case 4 (Crash)
        //Check if player hit a game object, play car crash sound and reset game. GAME OVER
        if contact.bodyA.node == player || contact.bodyB.node == player {
            
            let sound = SKAction.playSoundFileNamed("car-crash.wav", waitForCompletion: false)
            run(sound)
            
            gameOver.alpha = 1
            gameState = .dead
            backgroundMusic.run(SKAction.stop())
            
            player.removeFromParent()
            speed = 0
        }
    }
}//END

    
    

