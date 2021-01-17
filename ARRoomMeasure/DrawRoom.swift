//
//  DrawRoom.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/17.
//

import UIKit

class DrawRoom: UIView {
    
    var plotArray: [[Float]] = [[100,100],[200,200],[300,300]]
    
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
        // 線
        let line = UIBezierPath()
//
//        // 最初の位置
//        line.move(to: CGPoint(x: 100, y: 100))
//        // 次の位置
//        line.addLine(to:CGPoint(x: 300, y: 150))
        
        
        line.move(to: CGPoint(x: 0, y: 0))
//        let minX = plotArray.min
//        let minY
        for i in 1 ..< plotArray.count {
            let x = CGFloat((plotArray[i][0] - plotArray[0][0]) * 5000)
            let y = CGFloat((plotArray[i][1] - plotArray[0][1]) * 5000)
            print(x)
            print(y)
            //line.move(to: CGPoint(x: x, y: y))
            line.addLine(to: CGPoint(x: x, y: y))
        }
        
        // 終わる
        line.close()
        // 線の色
        UIColor.gray.setStroke()
        // 線の太さ
        line.lineWidth = 2.0
        // 線を塗りつぶす
        line.stroke()
        
    }
    
}