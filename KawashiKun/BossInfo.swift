//
//  BossInfo.swift
//  KawashiKun
//
//  Created by Shoma Yamaguchi on 2015/11/07.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

import SpriteKit

class BossInfo {
    var char:SKSpriteNode? = nil
    var lifeGuageBase:SKSpriteNode? = nil
    var lifeGuage:SKSpriteNode? = nil
    let charName = "Boss"
    let playerspeed:CGFloat = 5.0       // 走る早さ
    let playerjump:CGFloat = 25.0       // ジャンプ力
    let maxLife:CGFloat = 100.0         // HP最大値
    var preLife:CGFloat = 100.0         // 現在のHP
    
    var motionStand:SKAction? = nil
    var motionJump:SKAction? = nil
    var motionRun:SKAction? = nil
    
    init(pos:CGPoint,mask:UInt32)
    {
        // キャラクター
        char = makeKawasikun(CGPoint(x:pos.x,y:pos.y), mask: mask)

        // ライフゲージベース
        lifeGuageBase = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: preLife, height: 10))
        lifeGuageBase?.position.x = 0
        lifeGuageBase?.position.y = -((char?.size.height)! / 2.0) - 10
        // キャラクターnodeと関連づけ
        char?.addChild(lifeGuageBase!)

        // ライフゲージ
        lifeGuage = SKSpriteNode(color: UIColor.yellowColor(), size: CGSize(width: maxLife, height: 10))
        lifeGuage?.position.x = 0
        lifeGuage?.position.y = -((char?.size.height)! / 2.0) - 10
        // キャラクターnodeと関連づけ
        char?.addChild(lifeGuage!)

        // create motion
        motionStand = makeStandMotion()
        motionJump = makeJumpMotion()
        motionRun = makeRunMotion()
    }
    
    /** キャラクター作成
    * 引数   : pos   初期位置
    *    	: mask  衝突判定マスク値
    * 戻り値 : キャラクターのスプライト情報
    */
    func makeKawasikun(pos:CGPoint,mask:UInt32) -> SKSpriteNode!
    {
        /* キャラクター設定 */
        let charactor = SKSpriteNode(imageNamed: "stand-0.gif")
        
        charactor.position = pos
        charactor.name = charName /* とりあえずファイル名をノードの識別子に設定 */
        
        /* スプライトの透明以外の箇所をボディに設定 */
        charactor.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "stand-0.gif"), size: charactor.size)
        charactor.physicsBody?.allowsRotation = false
        charactor.physicsBody?.contactTestBitMask = mask
        charactor.physicsBody?.friction = 1.0
        charactor.physicsBody?.restitution = 0.0
        
        let action = makeStandMotion()
        let endlessAction = SKAction.repeatActionForever(action)
        charactor.runAction(endlessAction)
        
        return charactor
    }
    
    /** 立ちアニメーション作成
    * 引数   :
    * 戻り値 :SKAction!
    */
    func makeStandMotion() -> SKAction!
    {
        /* キャラクター設定 */
        let charactor = SKSpriteNode(imageNamed: "stand-0.gif")
        var animationFramesFarmer:[SKTexture] = []
        
        for(var i = 0; i <= 1; i++)
        {
            let name = NSString(format: "stand-%i.gif", i)
            let texture = SKTexture(imageNamed: name as String)
            animationFramesFarmer.append(texture)
        }
        
        charactor.xScale = 1.0
        charactor.yScale = 1.0
        
        let action = SKAction.animateWithTextures(animationFramesFarmer,timePerFrame:0.1)
        
        return action
    }
    
    /** 攻撃のnode作成
    * 引数   ：pos nodeの位置
    *       ：way  nodeを移動させる方向(true:右、false:左)
    * 戻り値 ：
    */
    func makeSquare(pos:CGPoint,way:Bool) -> SKShapeNode!
    {
        // 飛んでく何か
        let square = SKShapeNode(rectOfSize: CGSize(width: 1.0, height: 1.0))   // 1dotの四角
        let move:CGFloat = way ? 100.0 : -100.0                                 // 移動量
        
        // 初期位置
        square.position = pos
        
        // アクションを作成(四角移動→移動後nodeを消す)
        let action = SKAction.moveTo(CGPoint(x:pos.x + move,y:pos.y), duration: 0.2)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([action,remove])
        
        // アクション登録
        square.runAction(sequence)
        return square
    }
    
    /** ジャンプアニメーション作成
    * 引数   :
    * 戻り値 :SKAction!
    */
    func makeJumpMotion() -> SKAction!
    {
        /* キャラクター設定 */
        let charactor = SKSpriteNode(imageNamed: "jump-0.gif")
        var animationFramesFarmer:[SKTexture] = []
        
        for(var i = 0; i <= 8; i++)
        {
            let name = NSString(format: "jump-%i.gif", i)
            let texture = SKTexture(imageNamed: name as String)
            animationFramesFarmer.append(texture)
        }
        
        charactor.xScale = 1.0
        charactor.yScale = 1.0
        
        let action = SKAction.animateWithTextures(animationFramesFarmer,timePerFrame:0.09)
        
        return action
    }
    
    /** 走りアニメーション作成
    * 引数   :
    * 戻り値 :SKAction!
    */
    func makeRunMotion() -> SKAction!
    {
        /* キャラクター設定 */
        let charactor = SKSpriteNode(imageNamed: "run-0.gif")
        var animationFramesFarmer:[SKTexture] = []
        
        for(var i = 0; i <= 9; i++)
        {
            let name = NSString(format: "run-%i.gif", i)
            let texture = SKTexture(imageNamed: name as String)
            animationFramesFarmer.append(texture)
        }
        
        charactor.xScale = 1.0
        charactor.yScale = 1.0
        
        let action = SKAction.animateWithTextures(animationFramesFarmer,timePerFrame:0.09)
        
        return action
    }
    
    /** キャラクターを動かす
    * 引数   : vextor 移動座標
    * 戻り値 :
    */
    func move(var vector:(x:CGFloat,y:CGFloat)) {
        // 下に行き過ぎないように補正
        if(vector.y > 0.0)
        {
            vector.y = 0.0
        }
        else if(vector.y < -0.45)
        {
            vector.y = -0.45
        }
        
        char?.position = CGPointMake((char?.position.x)! + vector.x * playerspeed,
            (char?.position.y)! - vector.y * playerjump)
        
        // キャラを反転(0のときは何もしない)
        if(vector.x < 0)
        {
            char?.xScale = -1.0
        }
        else if(0 < vector.x)
        {
            char?.xScale = 1.0
        }
    }
    
    /** キャラクターにダメージを与える
    * 引数   : value ダメージ値
    * 戻り値 :
    */
    func givenDamage(value:CGFloat) {
        preLife -= value
        
        // ライフゲージを現在HPに合わせて修正
        lifeGuage?.size.width = preLife
        lifeGuage?.position.x -= value / 2.0
        
        // ダメージを受け続けて、HPがなくなったら消える
        if(preLife <= 0)
        {
            // 爆発してからキャラを消す
            char?.parent?.addChild(createBomb())
            char?.removeFromParent()
        }
    }
    
    /* 爆破処理 */
    func createBomb () -> SKEmitterNode {
        let path:String! = NSBundle.mainBundle().pathForResource("BombEnemy", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! SKEmitterNode

        // BOSSと同じ位置で爆発
        particle.position = (char?.position)!
        
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
