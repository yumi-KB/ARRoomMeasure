//
//  DrawRoom.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/17.
//

import UIKit

final class DrawRoom: UIView {
    
    let constraint = 15.0
    let buttonSize = 50.0
    
    private var plotArray: [[Float]] = []
    private var distanceArray: [Float] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Set Methods
    func setPlotArray(_ array: [[Float]]) {
        self.plotArray = array
    }
    
    func setDistanceArray(_ array: [Float]) {
        self.distanceArray = array
    }
    
    // MARK: - draw method
    override func draw(_ rect: CGRect) {
        // 図形描画用の線
        let line = UIBezierPath()
        // 間取り図を描画
        drawRoomLine(line)
        
        /* translation 最小値Yを持つ座標を原点に移すように図形全体を平行移動 */
        // Yについての最小値を持つ配列のインデックスを記録
        let minYIndex = getMinYIndex(array: plotArray)
        // Yの最小値を持つ座標を原点に、図形全体を平行移動
        var transX = plotArray[minYIndex][0]
        var transY = plotArray[minYIndex][1]
        var translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY)).inverted()
        line.apply(translation)
        
        // 座標全体を平行移動
        var transArray = transPlot(transX: transX, transY: transY, array: plotArray)
        /* */
        
        /* rotate 原点を中心に回転 */
        var angle: Float!
        var before: Int = 0
        if minYIndex == 0 {
            before = plotArray.count-1
        } else {
            before = minYIndex-1
        }
        
        var after: Int = 0
        if minYIndex == plotArray.count-1 {
            after = 0
        } else {
            after = minYIndex+1
        }
        
        if plotArray[before][1] < plotArray[after][1] {
            angle = atan((Float(plotArray[before][1])-Float(plotArray[minYIndex][1])) / (Float(plotArray[before][0])-Float(plotArray[minYIndex][0])))
        } else {
            angle = atan((plotArray[after][1]-plotArray[minYIndex][1]) / (plotArray[after][0]-plotArray[minYIndex][0]))
        }
        let rotation = CGAffineTransform(rotationAngle: CGFloat(angle)).inverted()
        line.apply(rotation)
        
        // rotate plot
        let rotateArray = rotatePlot(angle: angle, array: transArray)
        print("ra: \(rotateArray)")
        
        //　回転後の図形の幅と高さを求める
        let rotateBezierWidth = getBezierWidth(array: rotateArray)
        let rotateBezierHeight = getBezierHeight(array: rotateArray)
        /* */
        
        // 初期位置に戻す
        transX = plotArray[minYIndex][0]
        transY = plotArray[minYIndex][1]
        translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY))
        line.apply(translation)
        transArray = transPlot(transX: -transX, transY: -transY, array: rotateArray)
        
        // 正の座標上に図形を平行移動
        let minXIndex = getMinXIndex(array: rotateArray)
        transX = transArray[minXIndex][0]
        transY = transArray[minYIndex][1]
        translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY)).inverted()
        line.apply(translation)
        transArray = transPlot(transX: transX, transY: transY, array: transArray)
        
        // 面積の計算
        let area = getArea(rotateArray)
        
        /* scare Viewの大きさに合わせて拡大 */
        let scaleX = (Float(self.bounds.width) - Float(2.0 * constraint)) / rotateBezierWidth
        let scaleY = (Float(self.bounds.height) - Float(2.0 * constraint + buttonSize + constraint)) / rotateBezierHeight
        var scale: Float!
        var scaleTransform: CGAffineTransform!
        if scaleX < scaleY {
            scale = scaleX
            scaleTransform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        } else {
            scale = scaleY
            scaleTransform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        }
        line.apply(scaleTransform)
        
        // scale plot
        let scaleArray = scalePlot(scale: scale, array: transArray)
        
        //　回転/拡大後の図形の幅と高さを求める
        let scaleBezierWidth = getBezierWidth(array: scaleArray)
        let scaleBezierHeight = getBezierHeight(array: scaleArray)
        /* */
        
        // viewの中心に図形を平行移動
        let centerView = [self.bounds.width / 2, self.bounds.height / 2]
        print("centerView: \(centerView)")
        let centerBezier = [scaleBezierWidth / 2, scaleBezierHeight / 2]
        var resultArray: [[Float]] = []
        
        if scaleBezierWidth < scaleBezierHeight {
            transX = Float(centerView[0]) - centerBezier[0]
            translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(0))
            resultArray = transPlot(transX: -transX, transY: 0, array: scaleArray)
        } else {
            transY = Float(centerView[1]) - centerBezier[1]
            translation = CGAffineTransform(translationX: CGFloat(0), y: CGFloat(transY))
            resultArray = transPlot(transX: 0, transY: -transY, array: scaleArray)
        }
        line.apply(translation)
        
        
        // 描画
        line.stroke()
        
        
        /* add distance label */
        var label = UILabel()
        let labelWidth = 100
        
        for i in 0..<resultArray.count {
            label = UILabel()
            label.backgroundColor = UIColor(white: 1, alpha: 0.95)
            
            var x: Float = 0.0
            var y: Float = 0.0
            if i < (resultArray.count-1) {
                let halfX: Float = (resultArray[i+1][0] + resultArray[i][0]) / 2.0
                let halfY: Float = (resultArray[i+1][1] + resultArray[i][1]) / 2.0
                x = halfX - (Float(labelWidth) / 2.0)
                y = halfY
                
            } else {
                let halfX: Float = (resultArray[0][0] + resultArray[i][0]) / 2.0
                let halfY: Float = (resultArray[0][1] + resultArray[i][1]) / 2.0
                x = halfX - (Float(labelWidth) / 2.0)
                y = halfY
            }
            
            label.frame = CGRect(x: CGFloat(x),
                                 y: CGFloat(y),
                                 width: CGFloat(labelWidth),
                                 height: 40)
            
            label.textAlignment = NSTextAlignment.center
            label.numberOfLines = 1
            let length = String(floor(distanceArray[i]*1000)/1000) + "m"
            label.text = length
            self.addSubview(label) //labelを表示
        }
        /* */
        
        /* add area label */
        let areaM2 = String(floor(area*100)/100) + "m2"
        let areaTatami = "約" + String(floor(area / 1.65 * 100) / 100) + "帖"
        
        let areaLabel = UILabel()
        areaLabel.backgroundColor = UIColor(white: 0.75, alpha: 0.93)
        areaLabel.numberOfLines = 2
        areaLabel.text = areaM2 + "\n" + areaTatami
        areaLabel.sizeToFit()
        areaLabel.textAlignment = NSTextAlignment.center
        
        let centerX = self.bounds.width / 2 - areaLabel.frame.width / 2
        let centerY = self.bounds.height / 2 - areaLabel.frame.height / 2
        areaLabel.frame = CGRect(x: centerX,
                                 y: centerY,
                                 width: areaLabel.frame.width,
                                 height: areaLabel.frame.height)
        
        self.addSubview(areaLabel)
        /* */
    }
    
    
    // MARK: - Private Methods
    private func drawRoomLine(_ line: UIBezierPath) {
        // 座標値
        let x = CGFloat(plotArray[0][0])
        let y = CGFloat(plotArray[0][1])
        // スタート位置
        line.move(to: CGPoint(x: x, y: y))
        // 線の追加
        for i in 1 ..< plotArray.count {
            let x = CGFloat((plotArray[i][0]))
            let y = CGFloat((plotArray[i][1]))
            print("x:\(x), y:\(y)")
            line.addLine(to: CGPoint(x: x, y: y))
        }
        // 視点と終点を結ぶ
        line.close()
        // 線の色
        UIColor.orange.setStroke()
        // 線の太さ
        line.lineWidth = 5.0
    }
    
    private func getMinXIndex(array: [[Float]]) -> Int {
        // XとY座標の最小値
        let minX = array.map { $0[0] }.min() ?? 0.0
        let minY = array.map { $0[1] }.min() ?? 0.0
        /* 最大値
         let maxX = array.map { $0[0] }.max() ?? 0.0
         let maxY = array.map { $0[1] }.max() ?? 0.0
         */
        // XとY座標の最小値を持つ配列番号
        var minXIndex = 0
        var minYIndex = 0
        for (i, value) in array.enumerated() {
            if array[i][0] == minX {
                minXIndex = i
            }
            /* if array[i][1] == minY {
             minYIndex = i
             }*/
        }
        return minXIndex
    }
    
    private func getMinYIndex(array: [[Float]]) -> Int {
        // XとY座標の最小値
        let minX = array.map { $0[0] }.min() ?? 0.0
        let minY = array.map { $0[1] }.min() ?? 0.0
        /* 最大値
         let maxX = array.map { $0[0] }.max() ?? 0.0
         let maxY = array.map { $0[1] }.max() ?? 0.0
         */
        // XとY座標の最小値を持つ配列番号
        var minXIndex = 0
        var minYIndex = 0
        for (i, value) in array.enumerated() {
            /* if array[i][0] == minX {
             minXIndex = i
             }*/
            if array[i][1] == minY {
                minYIndex = i
            }
        }
        return minYIndex
    }
    
    private func getArea(_ array: [[Float]]) -> Float {
        var area: Float = 0
        for i in 0..<array.count-1 {
            let x = array[i][0] - array[i+1][0]
            let y = array[i][1] + array[i+1][1]
            area += x * y
        }
        let x = array[array.count-1][0] - array[0][0]
        let y = array[array.count-1][1] + array[0][1]
        area += x * y
        
        area = abs(area) / 2.0
        return area
    }
    
    private func transPlot(transX: Float, transY: Float, array: [[Float]]) -> [[Float]] {
        var transArray = array
        for i in 0..<array.count {
            transArray[i][0] = array[i][0] - transX
            transArray[i][1] = array[i][1] - transY
        }
        return transArray
    }
    
    private func scalePlot(scale: Float, array: [[Float]]) -> [[Float]] {
        var scaleArray = array
        for i in 0..<array.count {
            scaleArray[i][0] = array[i][0]*scale
            scaleArray[i][1] = array[i][1]*scale
        }
        return scaleArray
    }
    
    private func rotatePlot(angle: Float, array: [[Float]]) -> [[Float]] {
        var rotateArray = array
        for i in 0..<array.count {
            let x = array[i][0]
            let y = array[i][1]
            /* CGAffineの回転は　反時計回り */
            /* 座標の回転は　時計回り　なのでangleの符号を逆転させる */
            rotateArray[i][0] = x * cos(-angle) - y * sin(-angle)
            rotateArray[i][1] = x * sin(-angle) + y * cos(-angle)
        }
        return rotateArray
    }
    
    private func getBezierWidth(array: [[Float]]) -> Float {
        let minX = array.map { $0[0] }.min() ?? 0.0
        let maxX = array.map { $0[0] }.max() ?? 0.0
        return maxX - minX
    }
    
    private func getBezierHeight(array: [[Float]]) -> Float {
        let minY = array.map { $0[1] }.min() ?? 0.0
        let maxY = array.map { $0[1] }.max() ?? 0.0
        return maxY - minY
    }
    
}
