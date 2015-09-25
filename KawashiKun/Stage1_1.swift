//
//  GameScene.swift
//  KawashiKun
//
//  Created by 山口 翔馬 on 2015/03/22.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//

import SpriteKit

//class GameScene: SKScene, DegitalPadViewDelegate {
class Stage1_1: SKScene,DegitalPadViewDelegate {
    let charName = "kawashikun"
    var stage:JSTileMap!
    var dPadVector:CGPoint!
    let playerspeed:CGFloat = 5.0       // 走る早さ
    let playerjump:CGFloat = 25.0       // ジャンプ力
    var lastUpdateTimeInterval:NSTimeInterval = 1
    var world:SKNode!
    let worldName = "world"
    let cameraName = "camera"
    
    var motionStand:SKAction?
    var motionJump:SKAction?
    var motionRun:SKAction?
    //    var dPad:DegitalPad = DegitalPad(frame: CGRect(x: 200, y: 200, width: 500, height: 300))
    
    //    var degitalPadScene:DegitalPadScene?
    
    override func didMoveToView(view: SKView) {
        print("scene1_1: \(self.frame)")
        
        /* Setup your scene here */
        self.backgroundColor = UIColor.grayColor()
        
        // world settings
        world = SKNode()
        world.name = worldName
        self.addChild(world)
        
        // camera settings
        let camera = SKNode()
        camera.name = cameraName
        world.addChild(camera)
        
        // create map
        stage = JSTileMap(named: "Stage1_1.tmx")
        stage.position = CGPoint(x: 0, y: 0)
        world.addChild(stage)
        
        // 地面を作る
        addFloor()
        
        // create motion
        motionStand = makeStandMotion()
        motionJump = makeJumpMotion()
        motionRun = makeRunMotion()
        
        // create player
        let char = makeKawasikun(CGPoint(x:self.frame.size.width *        0.2,y:self.frame.size.height * 0.5), mask: 0)
        world.addChild(char)
        
        // create DPad
        //        self.degitalPadScene = DegitalPadScene(size: self.frame.size)
        //        self.degitalPadScene?.delegatePad = self
        dPadVector = CGPoint(x: 0, y: 0)
        //        self.addChild(self.degitalPadScene!)
        //        world.addChild(degitalPadScene!)
        //        self.addChild(self.dPad!)
        //        dPad.delegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for _ in touches {
//            let location = touch.locationInNode(self)
            let player = world.childNodeWithName(charName)
            
            player?.runAction(SKAction.repeatActionForever(motionRun!))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // パッド削除
        //        self.dPad.removeFromParent()
        let player = world.childNodeWithName(charName)
        
        player?.runAction(SKAction.repeatActionForever(motionStand!))
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
//        var animationFramesFarmer:[SKTexture] = []
        /*
        for(var i = 0; i <= 1; i++)
        {
        var name = NSString(format: "stand-%i.gif", i)
        var kawasikun = SKTexture(imageNamed: name)
        animationFramesFarmer.append(kawasikun)
        }
        
        charactor.xScale = 1.0
        charactor.yScale = 1.0*/
        charactor.position = pos
        charactor.name = charName /* とりあえずファイル名をノードの識別子に設定 */
        
        /* キャラクター画像の横幅サイズを半径とした円形を判定部分に設定 */
        //        charactor.physicsBody = SKPhysicsBody(circleOfRadius:charactor.size.width/2)
        //        let charbody = SKPhysicsBody(texture: charactor, size: charactor.size)
        charactor.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "stand-0.gif"), size: charactor.size)
        charactor.physicsBody?.allowsRotation = false
        charactor.physicsBody?.contactTestBitMask = mask
        charactor.physicsBody?.friction = 1.0
        charactor.physicsBody?.restitution = 0.0
        
        //        let action = SKAction.animateWithTextures(animationFramesFarmer,timePerFrame:0.1)
        let action = makeStandMotion()
        let endlessAction = SKAction.repeatActionForever(action)
        charactor.runAction(endlessAction)
        
        return charactor
    }
    
    /** 立ちアニメーション作成
    * 引数   :
    * 戻り値 :
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
    
    /** ジャンプアニメーション作成
    * 引数   :
    * 戻り値 :
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
    * 戻り値 :
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
    
    func addFloor() {
        for var a = 0; a < Int(stage.mapSize.width); a++ { //Go through every point across the tile map
            for var b = 0; b < Int(stage.mapSize.height); b++ { //Go through every point up the tile map
                let layerInfo:TMXLayerInfo = stage.layers.firstObject as! TMXLayerInfo //Get the first layer (you may want to pick another layer if you don't want to use the first one on the tile map)
                let point = CGPoint(x: a, y: b) //Create a point with a and b
                let gid = layerInfo.layer.tileGidAt(layerInfo.layer.pointForCoord(point)) //The gID is the ID of the tile. They start at 1 up the the amount of tiles in your tile set.
                
                if gid == 8 { //My gIDs for the floor were 7 so I checked for those values
                    let node = layerInfo.layer.tileAtCoord(point) //I fetched a node at that point created by JSTileMap
                    node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size) //I added a physics body
                    node.physicsBody?.dynamic = false
                    
                    //You now have a physics body on your floor tiles! :)
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        let player = world.childNodeWithName(charName)
        var vector = (x:dPadVector.x,y:dPadVector.y)
        
        // 下に行き過ぎないように補正
        if(vector.y > 0.0)
        {
            vector.y = 0.0
        }
        
        player!.position = CGPointMake(player!.position.x + vector.x * playerspeed,
            player!.position.y - vector.y * playerjump)
        //                    println("\(player!.position)")
        // カメラの移動
        let camera = world.childNodeWithName(cameraName)
        
        if((self.frame.size.width / 2) < player!.position.x) {
            camera?.parent?.position = CGPointMake(-player!.position.x + CGRectGetMidX(self.frame), camera!.parent!.position.y)
        }
        
        // キャラを反転
        if(dPadVector.x < 0)
        {
            player!.xScale = -1.0
        }
        else
        {
            player!.xScale = 1.0
        }
        
        //        player?.runAction(SKAction.repeatActionForever(motionRun!))
    }
    
    func setDegitalPadInfo(degitalPad: DegitalPadView) {
//        let onTouch = degitalPad.onToutch
        dPadVector = degitalPad.inputVector
    }
}
