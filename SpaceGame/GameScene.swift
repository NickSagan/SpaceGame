//
//  GameScene.swift
//  SpaceGame
//
//  Created by Nick Sagan on 13.11.2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var playAgain: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    var timeInterval = 1.0
    var enemiesCreatedNumber = 0

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        starfield.name = "bg"
        addChild(starfield)
        starfield.zPosition = -1
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self // tell us when contact happen
        
        startGame()
    }
    
    func startGame() {
        
        if scoreLabel != nil{
            scoreLabel.removeFromParent()
        }
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.name = "score"
        addChild(scoreLabel)
        
        score = 0
        timeInterval = 1.0
        enemiesCreatedNumber = 0
        isGameOver = false
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    func finishGame() {
        for child in self.children {
            if child.name == "bg" || child.name == "score" {
                continue
            }
            child.removeFromParent()
        }
        
        playAgain = SKLabelNode(fontNamed: "Chalkduster")
        playAgain.position = CGPoint(x: 512, y: 384)
        playAgain.horizontalAlignmentMode = .center
        playAgain.fontSize = 54
        playAgain.name = "playAgain"
        playAgain.text = "Play again"
        addChild(playAgain)
    }

    @objc func createEnemy() {
        enemiesCreatedNumber += 1
        guard let enemy = possibleEnemies.randomElement() else {return}
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        if enemiesCreatedNumber % 20 == 0 {
            timeInterval -= 0.1
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
            if !isGameOver {
                score += 1
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
        
        // Make a little delay
//        let moveToFinger = SKAction.move(to: location, duration: 0.3)
//        player.run(moveToFinger)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let moveToBase = SKAction.move(to: CGPoint(x: 50, y: 384), duration: 0.3)
        player.run(moveToBase)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if playAgain != nil {
            if objects.contains(playAgain) {
                playAgain.removeFromParent()
                startGame()
            }
        }
    }
    
    // if contact happens
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        isGameOver = true
        gameTimer?.invalidate()
        
        let wait = SKAction.wait(forDuration: 1)
        let finish = SKAction.run {self.finishGame()}
        let sequence = SKAction.sequence([wait, finish])
        run(sequence)
    }
}
