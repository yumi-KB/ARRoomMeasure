//
//  RoomImageViewController.swift
//  ARRoomMeasure
//
//  Created by yumi kanebayashi on 2021/01/16.
//

import UIKit

final class RoomImageViewController: UIViewController {
    
    /// オブジェクトの2次元座票を記録
    var plotArray: [[Float]] = []
    /// オブジェクト間の測定した距離を記録
    var distanceArray: [Float] = []
    
    /// オブジェクト間の制約
    var constraint = 15.0
    /// ボタンのサイズ
    var buttonSize = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        // 間取り図Viewの生成
        let drawRoom = makeRoomView()
        // viewで配列変数を使えるようにする
        drawRoom.setPlotArray(plotArray)
        drawRoom.setDistanceArray(distanceArray)
        
        // 間取り図imageViewに変換
        let roomImageView = makeRoomImageView(view: drawRoom)
        
        // UIImageView にタップイベントを追加
        roomImageView.isUserInteractionEnabled = true
        roomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.saveImage(_:))))

        self.view.addSubview(roomImageView)
    }
    
    
    // MARK: - Methods
    private func makeRoomView() -> DrawRoom {
        /// 間取り図viewの座標とサイズの設定
        let x = CGFloat(constraint)
        let y = CGFloat(constraint+(buttonSize+constraint)+constraint)
        let viewWidth = view.bounds.width - CGFloat(2.0 * constraint)
        let viewHeight = view.bounds.height - CGFloat(2.0 * constraint + (buttonSize+constraint)+constraint)
        
        // UIViewを継承したDrawRoomクラスのインスタンスを生成
        let drawRoom = DrawRoom(frame: CGRect(
                                    x: x,
                                    y: y,
                                    width: viewWidth,
                                    height: viewHeight))
        drawRoom.backgroundColor = UIColor.red
        return drawRoom
    }
    
    private func makeRoomImageView(view drawRoom: UIView) -> UIImageView {
        let image = drawRoom.convertToImage()
        let roomImageView = UIImageView(image: image)
        
        /// 間取り図imageViewの座標とサイズの設定
        let x = CGFloat(constraint)
        let y = CGFloat(constraint+(buttonSize+constraint)+constraint)
        let viewWidth = view.bounds.width - CGFloat(2.0 * constraint)
        let viewHeight = view.bounds.height - CGFloat(2.0 * constraint + (buttonSize+constraint)+constraint)
        roomImageView.frame = CGRect(
            x: x,
            y: y,
            width: viewWidth,
            height: viewHeight
        )
        return roomImageView
    }
    
    @objc func saveImage(_ sender: UITapGestureRecognizer) {
        // タップしたUIImageViewを取得
        let targetImageView = sender.view! as! UIImageView
        // その中の UIImage を取得
        let targetImage = targetImageView.image!
        // 保存するか否かのアラート
        let alertController = UIAlertController(title: "保存", message: "この画像を保存しますか？", preferredStyle: .alert)
        // OK
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            // フォトライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(targetImage, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        // CANCEL
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
            alertController.dismiss(animated: true, completion: nil)
        }
        // OKとCANCELを表示追加し、アラートを表示
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
           var title = "保存完了"
           var message = "カメラロールに保存しました"
           if error != nil {
               title = "エラー"
               message = "保存に失敗しました"
           }
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
    
    // MARK: - Action
    @IBAction func PopupClosed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
