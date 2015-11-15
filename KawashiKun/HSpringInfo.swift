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
    let jumpvector:CGFloat = 0.5       // ジャンプ力
    
    var motionJump:SKAction!
    
    init(pos:CGPoint,mask:UInt32)
    {
        // オブジェクト
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
        /* スプライト設定 */
        let sprite = SKSpriteNode(imageNamed: "HSpring_00.png")
        
        sprite.position = pos
        sprite.position.x += sprite.size.width / 2
        sprite.position.y += sprite.size.height / 2
        sprite.name = objectName /* とりあえずファイル名をノードの識別子に設定 */
        
        /* スプライトの透明以外の箇所をボディに設定 */
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
        /* スプライト設定 */
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
     * 引数   : partner ぶつかってきた相手
     * 戻り値 :
     */
    func jump(partner:SKNode) {
        let vec:CGVector = CGVector(dx: -jumpvector, dy: 0.0)
        
        // ぶつかってきた相手を飛ばす
        partner.physicsBody?.applyImpulse(vec)
        
        // バネのアニメーション
        object?.runAction(motionJump)
    }
}
