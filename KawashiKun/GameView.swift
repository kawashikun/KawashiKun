//
//  GameView.swift
//  KawashiKun
//
//  Created by 山口 翔馬 on 2015/09/04.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//

import Foundation
import SpriteKit

protocol ChangeSceneProtcol {
    func changeScene(sceneName:String)
}

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            var sceneData = NSData()
            do {
                try sceneData = NSData(contentsOfFile: path, options:NSDataReadingOptions.DataReadingMappedIfSafe)
                
            } catch {
                abort()
            }
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            switch file {
            case "TitleScene":
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! TitleScene
                archiver.finishDecoding()
                return scene
            case "GameScene":
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
                archiver.finishDecoding()
                return scene
            case "Stage1_1":
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! Stage1_1
                archiver.finishDecoding()
                return scene
            case "Stage1_2":
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! Stage1_2
                archiver.finishDecoding()
                return scene
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

class GameView:SKView,ChangeSceneProtcol {
    var changeViewDelegate:ChangeViewProtcol!
    var dPadView:DegitalPadView! = nil
    var dPadVactor:CGPoint! = nil

    init(frame: CGRect, sceneName:String) {
        print("gameview: \(frame)")

        super.init(frame: frame)
        
        // パッド生成
        self.dPadView = DegitalPadView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))

        changeScene(sceneName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentTitleScene() {
        // シーン作成
        let newScene = TitleScene.unarchiveFromFile("TitleScene") as? TitleScene
        newScene?.changeSceneDelegate = self

        //scene切り替え
        self.presentScene(newScene)
    }
    
    func presentGameScene() {
        // シーン作成
        let newScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        newScene?.changeSceneDelegate = self

        // viewに登録されていなかったら登録する
        if(!(self.dPadView.isDescendantOfView(self)))
        {
            self.addSubview(self.dPadView)
        }
        self.dPadView.delegate = newScene

        //scene切り替え
        self.presentScene(newScene)
    }
    
    func presentStage1_1() {
        // シーン作成
        let newScene = Stage1_1.unarchiveFromFile("Stage1_1") as? Stage1_1
        newScene?.changeSceneDelegate = self
        
        // viewに登録されていなかったら登録する
        if(!(self.dPadView.isDescendantOfView(self)))
        {
            self.addSubview(self.dPadView)
        }
        self.dPadView.delegate = newScene
        
        //scene切り替え
        self.presentScene(newScene)
    }
    
    func presentStage1_2() {
        // シーン作成
        let newScene = Stage1_2.unarchiveFromFile("Stage1_2") as? Stage1_2
        newScene?.changeSceneDelegate = self
        
        // viewに登録されていなかったら登録する
        if(!(self.dPadView.isDescendantOfView(self)))
        {
            self.addSubview(self.dPadView)
        }
        self.dPadView.delegate = newScene
        
        //scene切り替え
        self.presentScene(newScene)
    }
    
    func changeScene(sceneName:String) {
        // シーン名をキーとして表示するシーンを切り替える
        switch sceneName {
        case "TitleScene":
            presentTitleScene()
            break
        case "GameScene":
            presentGameScene()
            break
        case "Stage1_1":
            presentStage1_1()
            break
        case "Stage1_2":
            presentStage1_2()
            break
        case "Score":
            break
        default:
            // シーン名が登録されていない場合はビューを切り替える(Debug)
            self.removeFromSuperview()
            self.changeViewDelegate.changeView()
            break
        }
    }
}