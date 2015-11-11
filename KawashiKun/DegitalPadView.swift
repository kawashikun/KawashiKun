
import SpriteKit

let gl_objcpp = ObjCppWwise()//Wwise: 20151007 ...ここじゃまずいが、とりあえず。TitleScene.swift、GameScene.swift でも参照する


// プロトコル宣言
protocol DegitalPadViewDelegate {
	func setDegitalPadInfo(degitalPad:DegitalPadView)
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?,degitalPad:DegitalPadView)
    func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?,degitalPad:DegitalPadView)
}

// クラス宣言
class DegitalPadView: SKView {
	var delegate:DegitalPadViewDelegate?
    var timer:NSTimer! = nil
    var myScene:SKScene! = nil
	var padBase:SKShapeNode!		// アケコンのパッドのベース部分
	var padHead:SKShapeNode!		// アケコンのパッドの上の部分(丸いとこ)
	
	var onToutch:Bool = false		// タッチされているかどうか
    var onToutchLast:Bool = true	// タッチされているかどうか
	
	var inputPos:CGPoint = CGPointMake(0, 0)		// 入力位置(タッチ開始位置と差分をとって入力具合を取得)
	var basePos:CGPoint = CGPointMake(0, 0)				// タッチ開始位置
	var inputVector:CGPoint = CGPointMake(0, 0)			// 最終的な入力ベクトル(x=-1.0～1.0、y=-1.0～1.0)

	var degitalPadRadius:CGFloat = 0.0 	// 半径
    // タイマー関連の設定
    let tapResponseTime:NSTimeInterval = 0.15
    var tapStartTime:NSTimeInterval = 0.0
    var tapCurTime:NSTimeInterval = 0.0

    var ww_hCntFoot:UInt16    = 0           //Wwise:
    var ww_hCntFootThre:UInt16    = 20      //Wwise:
    var ww_hBeforeMove:UInt16 = 0           //Wwise:
    var ww_hDiff_x:UInt16 = 0               //Wwise:

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.multipleTouchEnabled = false
        
        // Initialization code
        // 半径を50くらいで適当に作成する
        self.degitalPadRadius = 30
        
        // パッドのベース
        self.padBase = SKShapeNode(circleOfRadius:self.degitalPadRadius)		// radiusサイズでベースを描画
        self.padBase.fillColor = UIColor(red:0.3,green:0.3,blue:0.3,alpha:0.3)
        
        // パッドの上の部分
        self.padHead = SKShapeNode(circleOfRadius:self.degitalPadRadius+10.0)	// 少し大きく
        self.padHead.fillColor = UIColor(red:0.5,green:0.0,blue:0.0,alpha:0.3)
        
        self.opaque = false
        let color = UIColor.blackColor().colorWithAlphaComponent(0.0)
        self.backgroundColor = color
        self.allowsTransparency = true
        
        myScene = SKScene(size: self.frame.size)
        myScene.backgroundColor = color
        self.presentScene(myScene)
        
        timerStart(0.01)
    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

    }

	

	// タッチ開始
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		/* Called when a touch begins */
		for touch: AnyObject in touches {
			let location = touch.locationInView(self)

			// タッチされている
            self.onToutch = true
            self.onToutchLast = false

			// タッチ開始位置保存
			self.inputPos = location
            self.basePos = location

            // パッドのベース
            self.padBase.position = CGPointMake(location.x,self.frame.height - location.y)
            myScene.addChild(padBase)

            // パッドの上の部分
            self.padHead.position = CGPointMake(location.x,self.frame.height - location.y)
            myScene.addChild(padHead)
        }

        // タッチしただけの時は入力ベクトルを0に戻す
        self.inputVector = CGPoint(x:0,y:0)

        tapStartTime = NSDate.timeIntervalSinceReferenceDate()

        self.delegate?.touchesBegan(touches, withEvent: event, degitalPad: self)
	}

	

	// ドラッグ処理
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		/* Called when a touch begins */
		for touch: AnyObject in touches {
            let location = touch.locationInView(self)
			// 入力位置

			self.inputPos = CGPointMake(location.x - self.basePos.x,
										location.y - self.basePos.y)

            /// Wwiseトライ >>>
            if ( ww_hBeforeMove > (UInt16)(self.basePos.x) ){
                ww_hDiff_x = ( ww_hBeforeMove - (UInt16)(self.basePos.x))
            }else{
                ww_hDiff_x = ( (UInt16)(self.basePos.x) - ww_hBeforeMove)
            }
            if (  ww_hDiff_x > ww_hBeforeMove ){
                ww_hCntFootThre--
                if ( ww_hCntFootThre < 10){
                    ww_hCntFootThre = 10
                }
            }else if ( ww_hDiff_x < ww_hBeforeMove  ){
                ww_hCntFootThre++
                if ( ww_hCntFootThre > 20){
                    ww_hCntFootThre = 20
                }
                
            }
            ww_hBeforeMove = ww_hDiff_x
            /// Wwiseトライ <<<

            
			// タッチ開始位置からの移動量算出
			// 長辺の2乗 + 短辺の2乗 = 対角線の2乗
			// 対角線 = root(長辺の2乗 + 短辺の2乗)
			let length = sqrt(pow(self.inputPos.x, 2.0) + pow(self.inputPos.y, 2.0))
            
			// パッドの半径より移動量が大きかったら補正
			if(length > self.degitalPadRadius) {
				inputPos.x = (inputPos.x / length) * self.degitalPadRadius;
				inputPos.y = (inputPos.y / length) * self.degitalPadRadius;
			}

			// パッドの上の部分
			self.padHead.position = CGPointMake(self.basePos.x + self.inputPos.x,
												self.frame.height - self.basePos.y - self.inputPos.y)

//            print("{1}\(self.basePos.x + self.inputPos.x),{2}\(self.frame.height - self.basePos.y - self.inputPos.y),{3}\(self.basePos),{4}\(self.inputPos)")

			// 移動量を -1.0 ～ 1.0 に補正
			self.inputVector.x = self.inputPos.x / self.degitalPadRadius
			self.inputVector.y = self.inputPos.y / self.degitalPadRadius


            print("\(self.inputVector)")
		}
        

	}
	
	// タッチ終了通知
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 位置初期化
        self.inputVector = CGPoint(x: 0, y: 0)
		
		// パッド削除
        self.padBase.removeFromParent()
        self.padHead.removeFromParent()
        
    tapCurTime = NSDate.timeIntervalSinceReferenceDate()
        let diffTime = tapCurTime - tapStartTime
        print("start:\(tapStartTime),cur:\(tapCurTime),diff:\(diffTime)")
        
        // タップ時間が短い場合は先にタッチ終了判定
        if (0.15 < diffTime)
        {
            self.delegate?.touchesEnded(touches, withEvent: event, degitalPad: self)
            
            // タッチ終了
            self.onToutch = false
            self.onToutchLast = true
        }
        else
        {
            // タッチ終了
            self.onToutch = false
            self.onToutchLast = true
            
            self.delegate?.touchesEnded(touches, withEvent: event, degitalPad: self)
            
            gl_objcpp.tmpGunFire()//Wwise : 20151010
        }
	}
    
    // タイマー開始
    func timerStart(interval:NSTimeInterval) {
        // タイマーを作る
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
    }
    
    func onUpdate(currentTime: CFTimeInterval) {

        // タップされていたらデリゲートを呼ぶ
        if(onToutch || onToutchLast) {
            self.delegate?.setDegitalPadInfo(self)
            
            self.onToutchLast = false

            ww_hCntFoot++
            if ( ww_hCntFoot > ww_hCntFootThre ){
                ww_hCntFoot = 0
                gl_objcpp.tmpFootStep()//Wwise: 20151010 Wwise test  あとでもっと間引くこと
            }
        }
    }
}