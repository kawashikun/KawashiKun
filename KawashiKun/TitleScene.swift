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
    let font_name = "Hiragino Kaku Gothic ProN W3"
    let button_start = "START"
    let button_resetscore = "RESET SCORE"
    
    override func didMoveToView(view: SKView) {
        print("titlescene: \(self.frame)")

        // 背景色
        self.backgroundColor = UIColor.redColor()

        // タイトルを表示。
        let myLabel = SKLabelNode(fontNamed:font_name)
        myLabel.text = "KawashiKun";
        myLabel.fontSize = 48;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        
        // 「Start」を表示。
        let startLabel = SKLabelNode(fontNamed: font_name)
        startLabel.text = button_start
        startLabel.fontSize = 36
        startLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: 200)
        startLabel.name = button_start
        self.addChild(startLabel)
    }
    
    // 「Start」ラベルをタップしたら、GameSceneへ遷移させる。
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch:UITouch = touches.first! {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
        
            if touchedNode.name != nil {
                if touchedNode.name == button_start {
                    changeScene("GameScene")
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
