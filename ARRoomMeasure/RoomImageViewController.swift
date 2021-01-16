//
//  RoomImageViewController.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/16.
//

import UIKit

class RoomImageViewController: UIViewController {
    
    var plotArray: [[Float]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Modal done!")
        print(plotArray)
    }
    
    @IBAction func PopupClosed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
