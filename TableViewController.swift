//
//  ViewController.swift
//  KawashiKun
//
//  Created by 山口 翔馬 on 2015/04/01.
//  Copyright (c) 2015年 yamaguchi. All rights reserved.
//


import UIKit
import SpriteKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView:UITableView!
    var scenes:NSArray = ["TitleScene","GameScene","Stage1_1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Status Barの高さを取得する.
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // TableViewの生成する(status barの高さ分ずらして表示).
        let myTableView: UITableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        
        // Cell名の登録をおこなう.
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        myTableView.dataSource = self
        
        // Delegateを設定する.
        myTableView.delegate = self
        
        // Viewに追加する.
        self.view.addSubview(myTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Num: \(indexPath.row)")
        println("Value: \(scenes[indexPath.row])")
        
        presentGameView(scenes[indexPath.row] as String)
    }
    
    /*
    Cellの総数を返す.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Cellの.を取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        
        // Cellに値を設定する.
        cell.textLabel!.text = "\(scenes[indexPath.row])"
        
        return cell
    }
    
    // ViewControllerをGameViewに切り替える
    func presentGameView(sceneName:String) {
        // ビュー作成
        let newView = SceneViewController()
        
        // 初期化時に表示するシーンの名前を保存しておく
        newView.sceneName = sceneName
        
        // ビュー切り替え
        newView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController(newView,animated:true,completion:nil)
    }
}
