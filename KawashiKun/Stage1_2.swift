//
//  GameScene.swift
//  KawashiKun
//
//  Created by 山口 翔馬 on 2015/03/22.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//

import SpriteKit

class Stage1_2: SKScene,DegitalPadViewDelegate,SKPhysicsContactDelegate,ChangeSceneProtcol {
    var changeSceneDelegate:ChangeSceneProtcol!
    var stage:JSTileMap!
    var dPadVector:CGPoint!
    var dPadTouch:Bool = false
    var dPadTouchLast:Bool = true
    var lastUpdateTimeInterval:NSTimeInterval = 1
    var world:SKNode!
    let worldName = "world"
    let cameraName = "camera"
    var playerInfo:PlayerInfo!      // PLAYERの情報
    var bossInfo:BossInfo!          // BOSSの情報
    var lowestShape:SKShapeNode!
    let bossMask:UInt32 = 0x1       // BOSSのマスク値
    let attackMask:UInt32 = 0x2     // 攻撃nodeのマスク値
    let springMask:UInt32 = 0x4     // バネnodeのマスク値
    let thornMask:UInt32 = 0x8      // 棘nodeのマスク値
    let playerMask:UInt32 = 0x80    // PLAYERのマスク値
    let outMask:UInt32 = 0x10       // 画面外に配置したnodeのマスク値
    var restart:Bool = false        // リスタートフラグ
    var springInfos:[HSpringInfo] = []
    var thornInfos:[ThornInfo] = []
    
    override func didMoveToView(view: SKView) {
        print("scene1_2: \(self.frame)")
        
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
        stage = JSTileMap(named: "Stage1_2.tmx")
        stage.position = CGPoint(x: 0, y: 0)
        world.addChild(stage)
        
        // 地面を作る
        addFloor()
        
        // オブジェクトを配置する
        addObjects()
        
        // create player
        playerInfo = PlayerInfo(pos: CGPoint(x:self.frame.size.width *        0.2,y:self.frame.size.height * 0.4), mask: playerMask)
        world.addChild(playerInfo.char!)
        
        // create DPad
        dPadVector = CGPoint(x: 0, y: 0)
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?, degitalPad: DegitalPadView) {
        /* Called when a touch begins */
        for _ in touches {
            let player = playerInfo.char
            player?.runAction(SKAction.repeatActionForever(playerInfo.motionRun!))
        }
    }
    
    func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?, degitalPad: DegitalPadView) {
        // タッチが終わったら立ちアニメーションに変更
        let player = playerInfo.char
        player?.runAction(SKAction.repeatActionForever(playerInfo.motionStand!))
        
        if degitalPad.onToutchLast {
            let player = playerInfo.char
            let way:Bool = (player?.xScale > 0.0) ? true : false
            
            world.addChild(playerInfo.makeSquare((player?.position)!,way:way))
        }
        
    }
    
    // タイルマップを生成する
    func addFloor() {
        for var a = 0; a < Int(stage.mapSize.width); a++ { //Go through every point across the tile map
            for var b = 0; b < Int(stage.mapSize.height); b++ { //Go through every point up the tile map
                for var c = 0; c < Int(stage.layers.count); c++ {
                    let layerInfo:TMXLayerInfo = (stage.layers as NSMutableArray)[c] as! TMXLayerInfo //Get the first                 
                    let point = CGPoint(x: a, y: b) //Create a point with a and b
                    let gid = layerInfo.layer.tileGidAt(layerInfo.layer.pointForCoord(point)) //The gID is the ID of the tile. They start at 1 up the the amount of tiles in your tile set.
                
                    if gid == 1 { //My gIDs for the floor were 7 so I checked for those values
                        let node = layerInfo.layer.tileAtCoord(point) //I fetched a node at that point created by JSTileMap
                        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size) //I added a physics body
                        node.physicsBody?.dynamic = false
                        node.physicsBody?.collisionBitMask = 0
                        node.physicsBody?.contactTestBitMask = 0
                        
                        /* 滑る床
                        node.physicsBody?.friction = 0.0
                         */
                    }
                }
            }
        }
        
        // 衝突判定用のノード
        lowestShape = SKShapeNode(rectOfSize: CGSize(width: self.size.width*3, height: 10))
        lowestShape.position = CGPoint(x: self.size.width*0.5, y: -20)
        
        // シェイプに合わせてボディ作成
        let physicsBody = SKPhysicsBody(rectangleOfSize: lowestShape.frame.size)
        
        physicsBody.dynamic = false
        physicsBody.contactTestBitMask = outMask
        lowestShape.physicsBody = physicsBody
        
        world.addChild(lowestShape)
    }
    
    // オブジェクトを配置する
    func addObjects() {
        // ObjectGroup検索
        let objGroups:NSMutableArray = stage.objectGroups as NSMutableArray
        for group in objGroups {
            // グループの情報を取得
            let groupInfo = (group as! TMXObjectGroup)
            // グループ名がbossだったら
            if(groupInfo.groupName == "boss")
            {
                // オブジェクトから設定取得
                for object in groupInfo.objects {
                    let dic = object as! NSDictionary
                    let x = dic["x"]! as! CGFloat       // x座標
                    let y = dic["y"]! as! CGFloat       // y座標
                    
                    // create boss
                    bossInfo = BossInfo(pos: CGPoint(x:x,y:y), mask: bossMask)
                    world.addChild(bossInfo.char!)
                    print(x,y)
                }
            }
            else if(groupInfo.groupName == "hspring")   // バネ追加
            {
                // オブジェクトから設定取得
                for object in groupInfo.objects {
                    let dic = object as! NSDictionary
                    let x = dic["x"]! as! CGFloat       // x座標
                    let y = dic["y"]! as! CGFloat       // y座標
                    
                    // create spring
                    let springInfo = HSpringInfo(pos: CGPoint(x:x,y:y), mask: springMask)
                    springInfos.append(springInfo)
                    world.addChild(springInfo.object!)
                    print(x,y)
                }
            }
            else if(groupInfo.groupName == "thorn")   // 棘追加
            {
                // オブジェクトから設定取得
                for object in groupInfo.objects {
                    let dic = object as! NSDictionary
                    let x = dic["x"]! as! CGFloat       // x座標
                    let y = dic["y"]! as! CGFloat       // y座標
                    
                    // create thorn
                    let thornInfo = ThornInfo(pos: CGPoint(x:x,y:y), mask: thornMask)
                    thornInfos.append(thornInfo)
                    world.addChild(thornInfo.object!)
                    print(x,y)
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        let vector = (x:dPadVector.x,y:dPadVector.y)
        
        // タッチされている時だけ処理
        if(dPadTouch)
        {
            print(vector)
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
            lowestShape.position.x = -(camera?.parent?.position.x)!
        }
        
    }
    
    func setDegitalPadInfo(degitalPad: DegitalPadView) {
        // 入力ベクトル取得
        dPadVector = degitalPad.inputVector
        
        // タッチ状態を取得(true:タッチされている、false:タッチされていない)
        dPadTouch = degitalPad.onToutch
        dPadTouchLast = degitalPad.onToutchLast
    }
    
    func changeScene(sceneName: String) {
        self.changeSceneDelegate.changeScene(sceneName)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {        
        // bossが存在する場合
        if let _ = getContactNode(contact,mask:bossMask)
        {
            /* 攻撃が当たった場合は、BOSSにダメージを与える */
            /* BOSSに当たるとnodeは消える */
            if let bodySub = getContactNode(contact,mask:attackMask)
            {
                bodySub.contactTestBitMask = 0
                bodySub.node?.removeFromParent()
                bossInfo.givenDamage(playerInfo.playerAttack)
            }
        }
        
        // playerが存在する場合
        if let bodyMain = getContactNode(contact,mask:playerMask)
        {
            if ((getContactNode(contact,mask:outMask) != nil) && (restart == false))    //　画面外のnode
            {
                // リスタート
                restart = true
                changeScene("Stage1_2")
            }
            else if let bodySub = getContactNode(contact,mask:springMask)   // バネ
            {
                for data in springInfos {
                    let springInfo = data
                    
                    // 同じノードなら跳ねる
                    if bodySub.node == springInfo.object {
                        springInfo.jump(bodyMain.node!)
                    }
                }
            }
            else if let bodySub = getContactNode(contact,mask:thornMask)   // 棘
            {
                bodySub.contactTestBitMask = 0
                for data in thornInfos {
                    let thornInfo = data
                    
                    // 同じノードなら爆発
                    if bodySub.node == thornInfo.object {
                        thornInfo.bomb(bodyMain.node!)
                        // 爆発が終わるぐらいの良い頃合いでシーンをリスタート
                        timer_wait()
                    }
                }
            }
        }
    }
    
    /*
    ビットマスクから衝突したbodyが存在するかチェック
    戻り値 nil:該当なし nil以外:該当したbodyを返す
    */
    func getContactNode(contact:SKPhysicsContact,mask:UInt32) -> SKPhysicsBody? {
        if((contact.bodyA.contactTestBitMask & mask) != 0)
        {
            return contact.bodyA
        }
        else if((contact.bodyB.contactTestBitMask & mask) != 0)
        {
            return contact.bodyB
        }
        
        return nil
    }
    
    var timer:NSTimer!
    var msec = 0
    
    // waitタイマー開始
    func timer_wait() {
        // タイマーを作る
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "onSecWait:", userInfo: nil, repeats: true)
    }
    
    // タイマー終了
    func timer_end() {
        // タイマーを破棄
        timer.invalidate()
        msec = 0
    }
    
    func onSecWait(time:NSTimer)
    {
        let stop = 80
        
        if(stop <= msec) {
            // タイマーの初期化
            timer_end()
            
            // シーンを切り替え
            changeScene("Stage1_2")
        }
        
        msec++
    }
}
