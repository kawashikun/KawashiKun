//
//  TitleScene.swift
//  HoleyBalloon
//
//  Created by 山口 翔馬 on 2015/02/15.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene,ChangeSceneProtcol {
    var changeSceneDelegate:ChangeSceneProtcol!
//    let font_name = "Hiragino Kaku Gothic ProN W3"
    let font_name = "Courier"
    let button_stage1 = "STAGE1     "
    let button_stage2 = "STAGE2     "
    let button_stage3 = "STAGE3     "
//    let label_text = "           "
    let label_text = "AAAAAAAAAAA"
    
    override func didMoveToView(view: SKView) {
        print("titlescene: \(self.frame)")

        // 背景色
        self.backgroundColor = UIColor.grayColor()
        
        // ゲームオーバーを表示
        let bg = SKSpriteNode(imageNamed: "Kawashi_Title_Draft.png")
        bg.position = CGPoint(x: (self.frame.width/2) , y: (self.frame.height/2))
        bg.size = CGSize(width: self.frame.width, height: self.frame.height)
        self.addChild(bg)
        
        let stage1_1Label = SKLabelNode(fontNamed: font_name)
        stage1_1Label.text = button_stage1
        stage1_1Label.fontSize = 36
        stage1_1Label.fontColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        stage1_1Label.position = CGPoint(x: (self.frame.width/2) + 200, y: 200)
        stage1_1Label.name = button_stage1
        self.addChild(stage1_1Label)
        
        let stage2_1Label = SKLabelNode(fontNamed: font_name)
        stage2_1Label.text = button_stage2
        stage2_1Label.fontSize = 36
        stage2_1Label.fontColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        stage2_1Label.position = CGPoint(x: (self.frame.width/2) + 200, y: 164)
        stage2_1Label.name = button_stage2
        self.addChild(stage2_1Label)
        
        let stage3_1Label = SKLabelNode(fontNamed: font_name)
        stage3_1Label.text = button_stage3
        stage3_1Label.fontSize = 36
        stage3_1Label.fontColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        stage3_1Label.position = CGPoint(x: (self.frame.width/2) + 200, y: 128)
        stage3_1Label.name = button_stage3
        self.addChild(stage3_1Label)
    }
    
    // 「Start」ラベルをタップしたら、GameSceneへ遷移させる。
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch:UITouch = touches.first! {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
        
            if touchedNode.name != nil {
                if touchedNode.name == button_stage1 {
                    changeScene("Stage1_1")
                }
                else if touchedNode.name == button_stage2 {
                    
                }
                else if touchedNode.name == button_stage3 {
                    
                }
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func changeScene(sceneName: String) {
        changeSceneDelegate.changeScene(sceneName)
    }
}
