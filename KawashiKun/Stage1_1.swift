//
//  GameScene.swift
//  KawashiKun
//
//  Created by 山口 翔馬 on 2015/03/22.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//

import SpriteKit

class Stage1_1: SKScene,DegitalPadViewDelegate,SKPhysicsContactDelegate,ChangeSceneProtcol {
    var changeSceneDelegate:ChangeSceneProtcol!
    var stage:JSTileMap!
    var dPadVector:CGPoint!
    var dPadTouch:Bool = false
    var lastUpdateTimeInterval:NSTimeInterval = 1
    var world:SKNode!
    let worldName = "world"
    let cameraName = "camera"
    var playerInfo:PlayerInfo!
    var bossInfo:BossInfo!
    let bossMask:UInt32 = 0x1
    let playerMask:UInt32 = 0x80
    let outMask:UInt32 = 0x10
    var restart:Bool = false
    
    override func didMoveToView(view: SKView) {
        print("scene1_1: \(self.frame)")
        
        /* Setup your scene here */
        self.backgroundColor = UIColor.grayColor()
        
        self.physicsWorld.contactDelegate = self
        
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
        
        // create player
        playerInfo = PlayerInfo(pos: CGPoint(x:self.frame.size.width *        0.2,y:self.frame.size.height * 0.5), mask: playerMask)
        world.addChild(playerInfo.char!)
        
        // create DPad
        dPadVector = CGPoint(x: 0, y: 0)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for _ in touches {
            let player = playerInfo.char
            let way:Bool = (player?.xScale > 0.0) ? true : false
            
            world.addChild(playerInfo.makeSquare((player?.position)!,way:way))
            player?.runAction(SKAction.repeatActionForever(playerInfo.motionRun!))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // タッチが終わったら立ちアニメーションに変更
        let player = playerInfo.char
        player?.runAction(SKAction.repeatActionForever(playerInfo.motionStand!))
    }
    
    func addFloor() {
        for var a = 0; a < Int(stage.mapSize.width); a++ { //Go through every point across the tile map
            for var b = 0; b < Int(stage.mapSize.height); b++ { //Go through every point up the tile map
//                let layerInfo:TMXLayerInfo = stage.layers.firstObject as! TMXLayerInfo //Get the first layer (you may want to pick another layer if you don't want to use the first one on the tile map)
                for var c = 0; c < Int(stage.layers.count); c++ {
                    let layerInfo:TMXLayerInfo = (stage.layers as NSMutableArray)[c] as! TMXLayerInfo //Get the first                 
                    let point = CGPoint(x: a, y: b) //Create a point with a and b
                    let gid = layerInfo.layer.tileGidAt(layerInfo.layer.pointForCoord(point)) //The gID is the ID of the tile. They start at 1 up the the amount of tiles in your tile set.
                
                    if gid == 8 { //My gIDs for the floor were 7 so I checked for those values
                        let node = layerInfo.layer.tileAtCoord(point) //I fetched a node at that point created by JSTileMap
                        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size) //I added a physics body
                        node.physicsBody?.dynamic = false
                    }
                    else if gid == 15 { //My gIDs for the floor were 7 so I checked for those values
                        let node = layerInfo.layer.tileAtCoord(point) //I fetched a node at that point created by JSTileMap
                        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size) //I added a physics body
                        node.physicsBody?.dynamic = false
                        node.physicsBody?.contactTestBitMask = outMask
                    }
                }
            }
        }
        
        // オブジェクトグループの情報を取得する方法
        let objInfo:TMXObjectGroup = stage.objectGroups.firstObject as! TMXObjectGroup
        
        let array = objInfo.objects as NSArray
        let dic = array[0] as! NSDictionary
        //        print((array[0] as! NSDictionary)["x"]!)
        let x = dic["x"]! as! CGFloat
        let y = dic["y"]! as! CGFloat
        print(x,y)
        
        // create boss
        bossInfo = BossInfo(pos: CGPoint(x:x,y:y), mask: bossMask)

        world.addChild(bossInfo.char!)
    }
    
    override func update(currentTime: CFTimeInterval) {
        var vector = (x:dPadVector.x,y:dPadVector.y)
        
        // 下に行き過ぎないように補正
        if(vector.y > 0.0)
        {
            vector.y = 0.0
        }
        
        // タッチされている時だけ処理
        if(dPadTouch)
        {
            // キャラクターの移動
            playerInfo.move(vector)
            //--------------------------------
            // Wwise周期処理呼び出し
            //--------------------------------
            gl_objcpp.tmpRenderAudio()  // 20151010
            
        }
        
        // カメラの移動
        let player = playerInfo.char
        let camera = world.childNodeWithName(cameraName)
        
        if((self.frame.size.width / 2) < player!.position.x) {
            camera?.parent?.position = CGPointMake(-player!.position.x + CGRectGetMidX(self.frame), camera!.parent!.position.y)
        }
        
    }
    
    func setDegitalPadInfo(degitalPad: DegitalPadView) {
        // 入力ベクトル取得
        dPadVector = degitalPad.inputVector
        
        // タッチ状態を取得(true:タッチされている、false:タッチされていない)
        dPadTouch = degitalPad.onToutch
    }
    
    func changeScene(sceneName: String) {
        self.changeSceneDelegate.changeScene(sceneName)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        /* AかBがBOSSの場合 */
        if ((contact.bodyA.contactTestBitMask & bossMask) != 0 || (contact.bodyB.contactTestBitMask & bossMask) != 0)
        {
            /* 攻撃が当たった場合は、BOSSにダメージを与える */
            /* BOSSに当たるとnodeは消える */
            if ((contact.bodyA.contactTestBitMask & 2) != 0)
            {
                contact.bodyA.contactTestBitMask = 0
                contact.bodyA.node?.removeFromParent()
                bossInfo.givenDamage(playerInfo.playerAttack)
            }
            else if ((contact.bodyB.contactTestBitMask & 2) != 0)
            {
                contact.bodyB.contactTestBitMask = 0
                contact.bodyB.node?.removeFromParent()
                bossInfo.givenDamage(playerInfo.playerAttack)
            }
        }
        
        /* AかBがPlayerの場合 */
        if ((contact.bodyA.contactTestBitMask & playerMask) != 0 || (contact.bodyB.contactTestBitMask & playerMask) != 0)
        {
            /* 画面外のnodeに当たるとリスタート */
            if (((contact.bodyA.contactTestBitMask & outMask) != 0) && restart == false)
            {
                changeScene("Stage1_1")
                restart = true
                print("changeA")
            }
            else if (((contact.bodyB.contactTestBitMask & outMask) != 0) && restart == false)
            {
                changeScene("Stage1_1")
                restart = true
                print("changeB")
            }
        }
    }
}
