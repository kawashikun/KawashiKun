//
//  PlayerInfo.swift
//  KawashiKun
//
//  Created by Shoma Yamaguchi on 2015/10/31.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

import SpriteKit


class PlayerInfo {
    var char:SKSpriteNode? = nil
    let charName = "kawashikun"
    let playerspeed:CGFloat = 5.0       // 走る早さ
    let playerjump:CGFloat = 25.0       // ジャンプ力
    let playerAttack:CGFloat = 10       // 攻撃力
    
    var motionStand:SKAction? = nil
    var motionJump:SKAction? = nil
    var motionRun:SKAction? = nil
    
    init(pos:CGPoint,mask:UInt32)
    {
        char = makeKawasikun(CGPoint(x:pos.x,y:pos.y), mask: mask)
        
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
        
        /* キャラクター画像の横幅サイズを半径とした円形を判定部分に設定 */
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
        
        /* nodeのサイズでボディ作成 */
        square.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1.0, height: 1.0))
        square.physicsBody?.allowsRotation = false
        square.physicsBody?.contactTestBitMask = 2 /*とりあえずの2 yamaguchi*/
        square.physicsBody?.friction = 0.0
        square.physicsBody?.restitution = 0.0
        square.physicsBody?.affectedByGravity = false
        
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
    func move(vector:(x:CGFloat,y:CGFloat)) {
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
}