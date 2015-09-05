//
//  SceneViewController.swift
//  KawashiKun
//
//  Created by 山口 翔馬 on 2015/04/01.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//
import UIKit
import SpriteKit

protocol ChangeViewProtcol {
    func changeView()
}

class SceneViewController: UIViewController,ChangeViewProtcol {
    var sceneName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("viewcontroller: \(self.view.frame)")
    
        let gameView = GameView(frame: self.view.frame, sceneName: sceneName)
        gameView.changeViewDelegate = self

        gameView.showsDrawCount = true
        gameView.showsFPS = true
        gameView.showsNodeCount = true
        gameView.showsFields = true
        gameView.showsQuadCount = true

        self.view = gameView
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func changeView() {
        
    }
}