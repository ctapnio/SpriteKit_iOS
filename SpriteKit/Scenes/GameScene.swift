//
//  GameScene.swift
//  SpriteKit
//
//  Created by ctapnio on 2022-04-09.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory{
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let BadGuy : UInt32 = 0b1
    static let GoodGuy : UInt32 = 0b10
    static let Projectile : UInt32 = 0b11
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var sportNode : SKSpriteNode?
    
    private var score : Int?
    let scoreIncrement = 25
    private var lblScore : SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        
        sportNode = SKSpriteNode(imageNamed: "jays.jpg")
        
         sportNode?.position = CGPoint(x: 100, y: 100)

        addChild(sportNode!)
        
        
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        physicsWorld.contactDelegate = self
        
        
        sportNode?.physicsBody = SKPhysicsBody(circleOfRadius: (sportNode?.size.width)!/2)
        sportNode?.physicsBody?.isDynamic = true
        sportNode?.physicsBody?.categoryBitMask = PhysicsCategory.GoodGuy
        sportNode?.physicsBody?.contactTestBitMask = PhysicsCategory.BadGuy
        sportNode?.physicsBody?.collisionBitMask = PhysicsCategory.None
        sportNode?.physicsBody?.usesPreciseCollisionDetection = true
        
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addBadGuy), SKAction.wait(forDuration: 1.5)])))

        
        score = 0
        self.lblScore = self.childNode(withName: "//score") as? SKLabelNode
        self.lblScore?.text = "Score: \(score!)"
        if let slabel = self.lblScore {
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }

    }
    
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min:CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max-min) + min
    }
    
    func addBadGuy(){
        
        let badGuy = SKSpriteNode(imageNamed: "fc.png")
        badGuy.xScale = badGuy.xScale * -1
        
        let actualY = random(min: badGuy.size.height/2, max: size.height-badGuy.size.height/2)
        
        badGuy.position = CGPoint(x: size.width + badGuy.size.width/2, y:actualY)
        
        addChild(badGuy)
        
        
        badGuy.physicsBody = SKPhysicsBody(rectangleOf: badGuy.size)
        badGuy.physicsBody?.isDynamic = true
        badGuy.physicsBody?.categoryBitMask = PhysicsCategory.BadGuy
        badGuy.physicsBody?.contactTestBitMask = PhysicsCategory.GoodGuy
        badGuy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        let actualDuration = random(min: CGFloat(4.0), max:CGFloat(8.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -badGuy.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        badGuy.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    
    func goodGuyDidCollideWithBadGuy(hero: SKSpriteNode, badGuy: SKSpriteNode){
        print("hit")
        
        
        score = score! + scoreIncrement
        self.lblScore?.text = "Score: \(score!)"
        if let slabel = self.lblScore {
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.BadGuy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.GoodGuy != 0)){
            goodGuyDidCollideWithBadGuy(hero: firstBody.node as! SKSpriteNode, badGuy: secondBody.node as! SKSpriteNode)
        }
    }
    
    
    func moveGoodGuy(toPoint pos : CGPoint){
        let actionMove = SKAction.move(to: pos, duration: TimeInterval( random(min: CGFloat(3.0), max:CGFloat(6.0))))
        let actionMoveDone = SKAction.rotate(byAngle: CGFloat(360.0), duration: TimeInterval( random(min: CGFloat(2.0), max:CGFloat(4.0))))
        sportNode?.run(SKAction.sequence([actionMove,actionMoveDone]))
    }

    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        
        moveGoodGuy(toPoint: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
            
            
            moveGoodGuy(toPoint: pos)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
