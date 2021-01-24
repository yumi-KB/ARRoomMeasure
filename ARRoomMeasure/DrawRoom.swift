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
    private var rotateArray: [[Float]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setArray(_ array: [[Float]]) {
        self.plotArray = array
        print(plotArray)
    }
    
    override func draw(_ rect: CGRect) {
        
      /*  plotArray = scaleArray(plotArray) */
        
        /* draw line */
        // 図形描画用の線
        let line = UIBezierPath()
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
        UIColor.blue.setStroke()
        // 線の太さ
        line.lineWidth = 5.0
        // 描画
        //line.stroke()
        /* */

        // XとY座標の最小値
        let minX = plotArray.map { $0[0] }.min() ?? 0.0
        let minY = plotArray.map { $0[1] }.min() ?? 0.0
        // 最大値
        let maxX = plotArray.map { $0[0] }.max() ?? 0.0
        let maxY = plotArray.map { $0[1] }.max() ?? 0.0
        
        // XとY座標の最小値を持つ配列番号
        var minXIndex = 0
        var minYIndex = 0
        for (i, value) in plotArray.enumerated() {
            if plotArray[i][0] == minX {
                minXIndex = i
            }
            if plotArray[i][1] == minY {
                minYIndex = i
            }
        }
        
        // Yの最小値を持つ座標を原点に、図形全体を平行移動
        var transX = plotArray[minXIndex][0] * (-1.0)
        var transY = plotArray[minYIndex][1] * (-1.0)
        print(transX)
        print(transY)
        var translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY))
        line.apply(translation)
        
//        // Yの最小値を持つ座標を原点に、図形全体を平行移動
//        var transX = plotArray[minYIndex][0] * (-1.0)
//        var transY = plotArray[minYIndex][1] * (-1.0)
//        print(transX)
//        print(transY)
//        var translation = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY))
//        line.apply(translation)
        
//        // rotate
//        var angle: Float!
//        var before: Int = 0 {
//            didSet {
//                if minYIndex == 0 {
//                    before = plotArray.count-1
//                } else {
//                    before = minYIndex-1
//                }
//            }
//        }
//        var after: Int = 0 {
//            didSet {
//                if minYIndex == plotArray.count-1 {
//                    after = 0
//                } else {
//                    after = minYIndex+1
//                }
//            }
//        }
//
//        if plotArray[before][1] < plotArray[after][1] {
//            angle = atan((plotArray[before][1]-plotArray[minYIndex][1]) / (plotArray[before][0]-plotArray[minYIndex][0]))
//        } else {
//            angle = atan((plotArray[after][1]-plotArray[minYIndex][1]) / (plotArray[after][0]-plotArray[minYIndex][0]))
//        }
//        angle = angle * 180 / Float.pi
//        let rotation = CGAffineTransform(rotationAngle: CGFloat(angle))
//        line.apply(rotation)
//
//        // rotate plot
//        rotateArray = rotatePlot(angle: angle, plotArray: plotArray)


        
        
//        // translation
//        transX = rotateArray[minXIndex][0] - plotArray[minYIndex][0]
//        translation = CGAffineTransform(translationX: CGFloat(transX), y: 0)
//        line.apply(translation)
        
  /* */
//        translation = CGAffineTransform(translationX: CGFloat(200.0), y: CGFloat(200.0))
//                line.apply(translation)
        //print(Float(self.bounds.width))
        
        // scare
        let scaleX = (Float(self.bounds.width) - Float(2.0 * constraint)) / (maxX - minX)
        let scaleY = (Float(self.bounds.height) - Float(2.0 * constraint + buttonSize + constraint)) / (maxY - minY)
        var scale: CGAffineTransform!
        if scaleX < scaleY {
            scale = CGAffineTransform(scaleX: CGFloat(scaleX), y: CGFloat(scaleX))
        } else {
            scale = CGAffineTransform(scaleX: CGFloat(scaleY), y: CGFloat(scaleY))
        }
        line.apply(scale)
        // 回転ごの座標のminMAX x,yについて調べてwidth heightを知る
        // modal.width/width scale
        // if modal.height < modal/widthばいした値 が大きくなってしまったら
        
        // modal.heigth/height倍に上書きする
        
        //        // invert translation
        //        let invert = CGAffineTransform(translationX: CGFloat(transX), y: CGFloat(transY)).inverted()
        //        line.apply(invert)

        
        line.stroke()
    }
    
    func getArea(_ plotArray: [[Float]]) -> Float {
        var area: Float = 0
        for i in 0..<plotArray.count-1 {
            let x =    plotArray[i][0] - plotArray[i+1][0]
            let y =    plotArray[i][1] + plotArray[i+1][1]
            area += x * y
        }
        let x = plotArray[plotArray.count-1][0] - plotArray[0][0]
        let y = plotArray[plotArray.count-1][1] + plotArray[0][1]
        area += x * y
        
        area = abs(area) / 2.0
        return area
    }
    
//    func scaleArray(_ plotArray: [[Float]]) -> [[Float]] {
//        var array: [[Float]] = plotArray
//        for i in 0..<plotArray.count {
//            array[i][0] = plotArray[i][0]*200
//            array[i][1] = plotArray[i][1]*200
//        }
//        return array
//    }
    
    func rotatePlot(angle: Float, plotArray: [[Float]]) -> [[Float]] {
        var rotateArray: [[Float]] = plotArray
        for i in 0..<plotArray.count {
            let x = plotArray[i][0]
            let y = plotArray[i][1]
            
            rotateArray[i][0] = x * cos(angle) - y * sin(angle)
            rotateArray[i][1] = x * sin(angle) + y * cos(angle)
        }
        return rotateArray
    }
    
    func getBezierWidth(array: [[Float]]) -> Float {
        let minX = array.map { $0[0] }.min() ?? 0.0
        let maxX = array.map { $0[0] }.max() ?? 0.0
        return minX + maxX
    }
    
    func getBezierHeight(array: [[Float]]) -> Float {
        let minY = array.map { $0[1] }.min() ?? 0.0
        let maxY = array.map { $0[1] }.max() ?? 0.0
        return minY + maxY
    }
    
}
