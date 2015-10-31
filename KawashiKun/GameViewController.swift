//
//  GameViewController.swift
//  KawashiKun
//
//  Created by 山口 翔馬 on 2015/03/22.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var dPadView:DegitalPadView! = nil
    var dPadVactor:CGPoint! = nil
    var sceneName:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            skView.ignoresSiblingOrder = true
            
            print("\(NSStringFromCGSize(skView.bounds.size))")
            scene.size = skView.bounds.size
            scene.scaleMode = .AspectFill
            
            // パッド生成
            self.dPadView = DegitalPadView(frame: CGRect(x: 0, y: 0, width: skView.bounds.width, height: skView.bounds.height))
            self.dPadView.delegate = scene
            
            skView.presentScene(scene)

            skView.addSubview(self.dPadView)
            
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
