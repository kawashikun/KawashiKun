
import SpriteKit

// プロトコル宣言
protocol DegitalPadViewDelegate {
	func setDegitalPadInfo(degitalPad:DegitalPadView)
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
}

// クラス宣言
class DegitalPadView: SKView {
	var delegate:DegitalPadViewDelegate?
    var timer:NSTimer! = nil
    var myScene:SKScene! = nil
    
	var padBase:SKShapeNode!		// アケコンのパッドのベース部分
	var padHead:SKShapeNode!		// アケコンのパッドの上の部分(丸いとこ)
	
	var onToutch:Bool = false		// タッチされているかどうか
    var onToutchLast:Bool = false	// タッチされているかどうか
	
	var inputPos:CGPoint = CGPointMake(0, 0)		// 入力位置(タッチ開始位置と差分をとって入力具合を取得)
	var basePos:CGPoint = CGPointMake(0, 0)				// タッチ開始位置
	var inputVector:CGPoint = CGPointMake(0, 0)			// 最終的な入力ベクトル(x=-1.0～1.0、y=-1.0～1.0)

	var degitalPadRadius:CGFloat = 0.0 	// 半径
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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

        self.delegate?.touchesBegan(touches, withEvent: event)

	}

	

	// ドラッグ処理
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		/* Called when a touch begins */
		for touch: AnyObject in touches {
            let location = touch.locationInView(self)
			// 入力位置

			self.inputPos = CGPointMake(location.x - self.basePos.x,
										location.y - self.basePos.y)

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
        
        // タッチ終了
        self.onToutch = false
        self.onToutchLast = true
        
        self.delegate?.touchesEnded(touches, withEvent: event)
	}
    
    // タイマー開始
    func timerStart(interval:NSTimeInterval) {
        // タイマーを作る
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
    }
    
    func onUpdate(currentTime: CFTimeInterval) {
        // タップされていたらデリゲートを呼ぶ
        if(onToutch || onToutchLast) {
            self.onToutchLast = false
            self.delegate?.setDegitalPadInfo(self)
        }
    }
}