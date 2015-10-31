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
    var dPadTouch:Bool = false
    let playerspeed:CGFloat = 5.0       // 走る早さ
    let playerjump:CGFloat = 25.0       // ジャンプ力
    var lastUpdateTimeInterval:NSTimeInterval = 1
    var world:SKNode!
    let worldName = "world"
    let cameraName = "camera"
    
    var motionStand:SKAction?
    var motionJump:SKAction?
    var motionRun:SKAction?
    
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
        dPadVector = CGPoint(x: 0, y: 0)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for _ in touches {
            let player = world.childNodeWithName(charName)
            let way:Bool = (player?.xScale > 0.0) ? true : false
            
            self.makeSquare((player?.position)!,way:way)
            player?.runAction(SKAction.repeatActionForever(motionRun!))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // パッド削除
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
    
    /** 攻撃のnode作成
    * 引数   ：pos nodeの位置
    *       ：way  nodeを移動させる方向(true:右、false:左)
    * 戻り値 ：
    */
    func makeSquare(pos:CGPoint,way:Bool)
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
        
        // node登録
        world.addChild(square)
        // アクション登録
        square.runAction(sequence)
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
        
        // オブジェクトグループの情報を取得する方法
        let objInfo:TMXObjectGroup = stage.objectGroups.firstObject as! TMXObjectGroup
        
        let array = objInfo.objects as NSArray
        let dic = array[0] as! NSDictionary
//        print((array[0] as! NSDictionary)["x"]!)
        let x = dic["x"]!
        print(x)
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
        // カメラの移動
        let camera = world.childNodeWithName(cameraName)
        
        if((self.frame.size.width / 2) < player!.position.x) {
            camera?.parent?.position = CGPointMake(-player!.position.x + CGRectGetMidX(self.frame), camera!.parent!.position.y)
        }
        
        // タッチされている時だけ処理
        if(dPadTouch)
        {
            // キャラを反転(0のときは何もしない)
            if(dPadVector.x < 0)
            {
                player!.xScale = -1.0
            }
            else if(0 < dPadVector.x)
            {
                player!.xScale = 1.0
            }
            //--------------------------------
            // Wwise周期処理呼び出し
            //--------------------------------
            gl_objcpp.tmpRenderAudio()  // 20151010

        }
    }
    
    func setDegitalPadInfo(degitalPad: DegitalPadView) {
        // 入力ベクトル取得
        dPadVector = degitalPad.inputVector
        
        // タッチ状態を取得(true:タッチされている、false:タッチされていない)
        dPadTouch = degitalPad.onToutch
    }
}
