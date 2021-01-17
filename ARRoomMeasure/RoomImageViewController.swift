//
//  RoomImageViewController.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/16.
//

import UIKit

final class RoomImageViewController: UIViewController {
    
    var plotArray: [[Float]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Modal done!")
        print(plotArray)
        
        let drawRoom = DrawRoom(frame: self.view.bounds)
        drawRoom.setArray(plotArray)
        self.view.addSubview(drawRoom)
    }
    
    @IBAction func PopupClosed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
