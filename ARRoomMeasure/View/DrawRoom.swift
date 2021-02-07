//
//  DrawRoom.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/17.
//

import UIKit

final class DrawRoom: UIView {
    /// オブジェクト間の制約
    let constraint = 15.0
    /// ボタンのサイズを表す変数
    let buttonSize = 50.0
    
    /// オブジェクトの2次元座票を記録
    private var plotArray: [[Float]] = []
    /// オブジェクト間の測定した距離を記録
    private var distanceArray: [Float] = []
    
    private var minYIndex: Int = 0
    private var minXIndex: Int = 0
    private var rotateBezierWidth: Float = 0.0
    private var rotateBezierHeight: Float = 0.0
    private var scaleBezierWidth: Float = 0.0
    private var scaleBezierHeight: Float = 0.0
    
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
        // Yについて最小値を持つ配列のインデックスを記録
        minYIndex = getMinYIndex(array: self.plotArray)
        
        // 原点に最小値Yを持つ座標を移すように図形を平行移動
        translateToOrigin(bezierPath: line, plot: self.plotArray)
        
        // 図形を回転
        rotate(bezierPath: line, plot: self.plotArray)
        // 回転後のXについて最小値を持つ配列のインデックスを記録
        minXIndex = getMinXIndex(array: self.plotArray)
        // 面積の計算
        let area = getArea(self.plotArray)
        //　回転後の図形の幅と高さを求める
        rotateBezierWidth = getBezierWidth(array: self.plotArray)
        rotateBezierHeight = getBezierHeight(array: self.plotArray)
        
        // 原点に平行移動させた図形を元の位置に平行移動
        translateToInitial(bezierPath: line, plot: self.plotArray)
        // 図形全体を正の座標上に収まるように平行移動
        translateToPositive(bezierPath: line, plot: self.plotArray)
        
        // 図形を拡大
        scale(bezierPath: line, plot: self.plotArray)
        //　回転/拡大後の図形の幅と高さを求める
        scaleBezierWidth = getBezierWidth(array: self.plotArray)
        scaleBezierHeight = getBezierHeight(array: self.plotArray)
        
        // Viewの中心に図形を平行移動
        translateToCenter(bezierPath: line, plot: self.plotArray)
        
        // 描画
        line.stroke()
        
        // 測定した辺の長さを示すラベルを追加
        addDistanceLabel()
        // 測定した面積を示すラベルを追加
        addAreaLabel(area)
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
            line.addLine(to: CGPoint(x: x, y: y))
        }
        // 視点と終点を結ぶ
        line.close()
        // 線の色
        UIColor.orange.setStroke()
        // 線の太さ
        line.lineWidth = 5.0
    }
    
    private func translateToOrigin(bezierPath line: UIBezierPath, plot plotArray: [[Float]]) {
        /* translation
         * 最小値Yを持つ座標を原点に移すように図形全体を平行移動 */
        // Yの最小値を持つ座標を原点に、図形全体を平行移動
        let transX = plotArray[minYIndex][0]
        let transY = plotArray[minYIndex][1]
        let translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY)).inverted()
        line.apply(translation)
        
        // 座標を原点に平行移動
        let transArray = transPlot(transX: transX, transY: transY, array: plotArray)
        setPlotArray(transArray)
    }
    
    private func rotate(bezierPath line: UIBezierPath, plot transArray: [[Float]]) {
        /* rotate
         * 原点を中心に回転 */
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
        
        // 座標を回転
        let rotateArray = rotatePlot(angle: angle, array: transArray)
        setPlotArray(rotateArray)
    }
    
    private func translateToInitial(bezierPath line: UIBezierPath, plot rotateArray: [[Float]]) {
        /* translation
         * 初期位置に戻す */
        let transX = plotArray[minYIndex][0]
        let transY = plotArray[minYIndex][1]
        let translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY))
        line.apply(translation)
        
        // 座標を初期位置に平行移動
        let transArray = transPlot(transX: -transX, transY: -transY, array: rotateArray)
        setPlotArray(transArray)
    }
    
    private func translateToPositive(bezierPath line: UIBezierPath, plot transArray: [[Float]]) {
        /* translation
         * 正の座標上に図形を平行移動 */
        let transX = transArray[minXIndex][0]
        let transY = transArray[minYIndex][1]
        let translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY)).inverted()
        line.apply(translation)
        
        // 座標を正の座標上に平行移動
        let array = transPlot(transX: transX, transY: transY, array: transArray)
        setPlotArray(array)
    }
    
    private func scale(bezierPath line: UIBezierPath, plot transArray: [[Float]]){
        /* scare
         * Viewの大きさに合わせて拡大 */
        let scaleX = (Float(self.bounds.width) - Float(2.0 * constraint)) / rotateBezierWidth
        let scaleY = (Float(self.bounds.height) - Float(2.0 * constraint + buttonSize + constraint + constraint)) / rotateBezierHeight
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
        
        // 座標を拡大
        let scaleArray = scalePlot(scale: scale, array: transArray)
        setPlotArray(scaleArray)
    }
    
    private func translateToCenter(bezierPath line: UIBezierPath, plot scaleArray: [[Float]]) {
        /* translation
         * viewの中心に図形を平行移動 */
        let centerView = [self.bounds.width / 2, self.bounds.height / 2]
        let centerBezier = [scaleBezierWidth / 2, scaleBezierHeight / 2]
        
        let transX = Float(centerView[0]) - centerBezier[0]
        let transY = Float(centerView[1]) - centerBezier[1]
        
        let translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY))
        line.apply(translation)
        
        let resultArray = transPlot(transX: -transX, transY: -transY, array: scaleArray)
        setPlotArray(resultArray)
    }
    
    private func getMinXIndex(array: [[Float]]) -> Int {
        // XとY座標の最小値
        let minX = array.map { $0[0] }.min() ?? 0.0
        let minY = array.map { $0[1] }.min() ?? 0.0
        // XとY座標の最小値を持つ配列番号
        var minXIndex = 0
        var minYIndex = 0
        for (i, value) in array.enumerated() {
            if array[i][0] == minX {
                minXIndex = i
            }
        }
        return minXIndex
    }
    
    private func getMinYIndex(array: [[Float]]) -> Int {
        // XとY座標の最小値
        let minX = array.map { $0[0] }.min() ?? 0.0
        let minY = array.map { $0[1] }.min() ?? 0.0
        // XとY座標の最小値を持つ配列番号
        var minXIndex = 0
        var minYIndex = 0
        for (i, value) in array.enumerated() {
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
    
    private func addDistanceLabel() {
        /* add distance label */
        var label = UILabel()
        let labelWidth = 100
        let labelHeight = 40
        
        for i in 0..<self.plotArray.count {
            label = UILabel()
            label.backgroundColor = UIColor(white: 1, alpha: 0.75)
            
            var x: Float = 0.0
            var y: Float = 0.0
            if i < (self.plotArray.count-1) {
                let halfX: Float = (self.plotArray[i+1][0] + self.plotArray[i][0]) / 2.0
                let halfY: Float = (self.plotArray[i+1][1] + self.plotArray[i][1]) / 2.0
                x = halfX - (Float(labelWidth) / 2.0)
                y = halfY - (Float(labelHeight) / 2.0)
                
            } else {
                let halfX: Float = (self.plotArray[0][0] + self.plotArray[i][0]) / 2.0
                let halfY: Float = (self.plotArray[0][1] + self.plotArray[i][1]) / 2.0
                x = halfX - (Float(labelWidth) / 2.0)
                y = halfY - (Float(labelHeight) / 2.0)
            }
            
            label.frame = CGRect(x: CGFloat(x),
                                 y: CGFloat(y),
                                 width: CGFloat(labelWidth),
                                 height: CGFloat(labelHeight ))
            
            label.textAlignment = NSTextAlignment.center
            label.numberOfLines = 1
            let length = String(floor(distanceArray[i]*1000)/1000) + "m"
            label.text = length
            // labelを表示
            self.addSubview(label)
        }
    }
    
    private func addAreaLabel(_ area: Float) {
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
        // areaLabelを表示
        self.addSubview(areaLabel)
    }
}
