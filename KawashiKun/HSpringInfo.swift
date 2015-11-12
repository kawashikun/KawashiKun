//
//  HSpringInfo.swift
//  KawashiKun
//
//  Created by Shoma Yamaguchi on 2015/11/13.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

import SpriteKit

class HSpringInfo {
    var object:SKSpriteNode? = nil
    let objectName = "HSpring"
    let jumpvector:CGFloat = 2.0       // ジャンプ力
    
    var motionJump:SKAction!
    
    init(pos:CGPoint,mask:UInt32)
    {
        // キャラクター
        object = makeObject(CGPoint(x:pos.x,y:pos.y), mask: mask)
        
        // create motion
        motionJump = makeJumpMotion()
    }
    
    /** オブジェクト作成
     * 引数   : pos   初期位置
     *    	: mask  衝突判定マスク値
     * 戻り値 : キャラクターのスプライト情報
     */
    func makeObject(pos:CGPoint,mask:UInt32) -> SKSpriteNode!
    {
        /* キャラクター設定 */
        let sprite = SKSpriteNode(imageNamed: "HSpring_00.png")
        
        sprite.position = pos
        sprite.position.x += sprite.size.width / 2
        sprite.position.y += sprite.size.height / 2
        sprite.name = objectName /* とりあえずファイル名をノードの識別子に設定 */
        
        /* キャラクター画像の横幅サイズを半径とした円形を判定部分に設定 */
        sprite.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "HSpring_00.png"), size: sprite.size)
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.contactTestBitMask = mask
        sprite.physicsBody?.friction = 1.0
        sprite.physicsBody?.restitution = 0.0
        sprite.physicsBody?.dynamic = false
        
        return sprite
    }
    
    /** ジャンプアニメーション作成
     * 引数   :
     * 戻り値 :SKAction!
     */
    func makeJumpMotion() -> SKAction!
    {
        /* キャラクター設定 */
        let sprite = SKSpriteNode(imageNamed: "HSpring_00.png")
        var animationFramesFarmer:[SKTexture] = []
        
        for(var i = 0; i <= 8; i++)
        {
            let name = NSString(format: "HSpring_0%i.png", i)
            let texture = SKTexture(imageNamed: name as String)
            animationFramesFarmer.append(texture)
        }
        
        sprite.xScale = 1.0
        sprite.yScale = 1.0
        
        let action = SKAction.animateWithTextures(animationFramesFarmer,timePerFrame:0.09)
        
        return action
    }
    
    /** ぶつかってきた物体をジャンプさせる
     * 引数   : vextor 移動座標
     * 戻り値 : CGVector 跳ね返り値
     */
    func jump() -> CGVector {
        let vec:CGVector = CGVector(dx: -jumpvector, dy: 0.0)
        
        // バネのアニメーション
        object?.runAction(motionJump)
        
        return vec
    }
}
