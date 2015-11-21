//
//  ThornInfo.swift
//  KawashiKun
//
//  Created by Shoma Yamaguchi on 2015/11/14.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

import SpriteKit

class ThornBallInfo {
    var object:SKSpriteNode? = nil
    let objectName = "ThornBall"
    
    init(pos:CGPoint,mask:UInt32)
    {
        // オブジェクト
        object = makeObject(CGPoint(x:pos.x,y:pos.y), mask: mask)
    }
    
    /** オブジェクト作成
     * 引数   : pos   初期位置
     *    	: mask  衝突判定マスク値
     * 戻り値 : キャラクターのスプライト情報
     */
    func makeObject(pos:CGPoint,mask:UInt32) -> SKSpriteNode!
    {
        /* スプライト設定 */
        let sprite = SKSpriteNode(imageNamed: "ThornBall_00.png")
        
        sprite.position = pos
        sprite.position.x += sprite.size.width / 2
        sprite.position.y += sprite.size.height / 2
        sprite.name = objectName /* とりあえずファイル名をノードの識別子に設定 */
        
        /* スプライトの透明以外の箇所をボディに設定 */
        sprite.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ThornBall_00.png"), size: sprite.size)
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = mask
        sprite.physicsBody?.friction = 1.0
        sprite.physicsBody?.restitution = 0.0
        sprite.physicsBody?.dynamic = false
        
        let action = makeThornMotion()
        let endlessAction = SKAction.repeatActionForever(action)
        sprite.runAction(endlessAction)
        
        return sprite
    }
    
    /** トゲトゲアニメーション作成
     * 引数   :
     * 戻り値 :SKAction!
     */
    func makeThornMotion() -> SKAction!
    {
        /* キャラクター設定 */
        let object = SKSpriteNode(imageNamed: "ThornBall_00.png")
        var animationFramesFarmer:[SKTexture] = []
        
        for(var i = 0; i <= 4; i++)
        {
            let name = NSString(format: "ThornBall_0%i.png", i)
            let texture = SKTexture(imageNamed: name as String)
            animationFramesFarmer.append(texture)
        }
        
        object.xScale = 1.0
        object.yScale = 1.0
        
        let action = SKAction.animateWithTextures(animationFramesFarmer,timePerFrame:0.04)
        
        return action
    }
    
    /** ぶつかってきた物体を爆発させる
     * 引数   : partner ぶつかってきた相手
     * 戻り値 :
     */
    func bomb(partner:SKNode) {
        
        // 爆発してからキャラを消す
        partner.parent?.addChild(createBomb(partner))
        partner.removeFromParent()
    }
    
    /* 爆破処理 */
    func createBomb (partner:SKNode) -> SKEmitterNode {
        let path:String! = NSBundle.mainBundle().pathForResource("BombEnemy", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! SKEmitterNode
        
        // BOSSと同じ位置で爆発
        particle.position = partner.position
        
        // particleのもろもろの設定を行ってみます。
        particle.numParticlesToEmit = 100 // 何個、粒を出すか。
        particle.particleBirthRate = 200 // 一秒間に何個、粒を出すか。
        particle.particleSpeed = 80 // 粒の速度
        particle.xAcceleration = 0
        particle.yAcceleration = 0 // 加速度を0にすることで、重力がないようになる。
        
        // 他にもいろいろあるけど、力つきた。。
        return particle
    }
}
