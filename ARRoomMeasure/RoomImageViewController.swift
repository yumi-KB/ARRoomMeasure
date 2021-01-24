//
//  RoomImageViewController.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/16.
//

import UIKit

final class RoomImageViewController: UIViewController {
    
    var plotArray: [[Float]] = []
    var constraint = 15.0
    var buttonSize = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Modal done!")
        print(plotArray)
    }
    
    override func viewWillLayoutSubviews() {
        print("width=\(view.bounds.width), height=\(view.bounds.height)")
        
        let viewWidth = view.bounds.width - CGFloat(2.0 * constraint)
        let viewHeight = view.bounds.height - CGFloat(2.0 * constraint + (constraint + buttonSize))
        
        let drawRoom = DrawRoom(frame: CGRect(x: CGFloat(constraint), y: CGFloat(constraint+(constraint+buttonSize)),
                                              width: viewWidth, height: viewHeight))
        drawRoom.setArray(plotArray)
        
        self.view.addSubview(drawRoom)
    }
    
    @IBAction func PopupClosed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
