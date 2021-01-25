import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    var coverView: UIView!
    
    let dotRadius: Float = 0.01
    /// 距離ノード
    var textNodes: [SCNNode] = []
    /// ドットノード
    var dotNodes: [SCNNode] = []
    /// 線ノード
    var lineNodes: [SCNNode] = []
    
    var lineLength: [Float] = []
    var firstY: Float = 0
    var plotArray: [[Float]] = []
    var distanceArray: [Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 配置・構成の作成
        let configuration = ARWorldTrackingConfiguration()
        /// 水平面の検出
        configuration.planeDetection = .horizontal
        /// セッションの開始
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // ドット上限を20個に指定
        if dotNodes.count >= 20 { return }
        // 最初にタップした座標を取り出す
        guard let touch = touches.first else { return }
        // スクリーン座標に変換する
        let touchLocation = touch.location(in: sceneView)
        // タップされた位置の特徴点にあるARアンカーを探す
        let hitTestResults = sceneView.hitTest(touchLocation, types: .existingPlane)
        
        // ARアンカーがあればオブジェクトを置く
        guard let hitResult = hitTestResults.first else { return }
        // スタート地点のオブジェクトは オレンジ色
        // その他は 白色
        if dotNodes == [] {
            /// スタート地点のy座標を保存
            /// 今後この座標上の平面を基準にドットを追加していく
            firstY = hitResult.worldTransform.columns.3.y
            /// ドットの追加
            addDot(at: hitResult, color: .systemOrange, y: firstY)
            
            /// 2次元座標の追加
            let x = dotNodes[dotNodes.count-1].position.x
            let z = dotNodes[dotNodes.count-1].position.z
            plotArray.append([x,z])
        } else {
            /// ドットの追加
            addDot(at: hitResult, color: .white, y: firstY)
            
            /// 2次元座標の生成
            let x = dotNodes[dotNodes.count-1].position.x
            let z = dotNodes[dotNodes.count-1].position.z
            plotArray.append([x,z])
            
            /// オレンジ色の一番最初のドットオブジェクト
            let startObject = dotNodes[0]
            /// 最後に追加したドットオブジェクト
            let endObject = dotNodes[dotNodes.count-1]
            /// ひとつ前のオブジェクトの座標
            let fromObject = dotNodes[dotNodes.count-2]
            
            // ラインの追加
            addLine(from: fromObject, to: endObject)
            
            // lineの長さを配列に格納
            let length = calculateDistance(from: fromObject, to: endObject)
            lineLength.append(length)
            
            // 距離文字列の追加
            // distance メートル
            let distance = floor(abs(length)*1000)/1000
            addDistance(text: "\(distance)m", from: fromObject, to: endObject)
            distanceArray.append(distance)
            
            /* もしスタートオブジェクトと重なれば、終了 */
            if objectsAreTouched(start: startObject, end: endObject) {
                // 最後のlineのエンドオブジェクトをスタートオブジェクトに置き換えて更新
                let updateLastLength = calculateDistance(from: fromObject, to: startObject)
                lineLength[lineLength.count-1] = updateLastLength
                // 重なった配列末尾を削除
                plotArray.removeLast()
                
                print("finish")
                // モーダルで画面遷移
                performSegue(withIdentifier: "RoomPopup", sender: self)
            }
        }
    }
    
    // MARK: - Action
    @IBAction private func UndoAction(_ sender: UIButton) {
        /* remove plot */
        if plotArray == [] {
            if plotArray.count > 0 { plotArray[0] = [0.0, 0.0] }
        } else {
            plotArray.remove(at: plotArray.count-1)
        }
        
        /* remove dot */
        if dotNodes == [] { return }
        // sceneViewから削除
        dotNodes.last?.removeFromParentNode()
        // 配列から削除
        dotNodes.removeLast()
        
        /* remove line */
        if lineNodes == [] { return }
        // sceneViewから削除
        lineNodes.last?.removeFromParentNode()
        // 配列から削除
        lineNodes.removeLast()
        
        /* remove text */
        if textNodes == [] { return }
        // sceneViewから削除
        textNodes.last?.removeFromParentNode()
        // 配列から削除
        textNodes.removeLast()
        distanceArray.removeLast()
    }
    
    
    // MARK: - Methods
    private func addLine(from: SCNNode, to: SCNNode) {
        // lineノードの作成
        let lineNode = drawLine(from: from.position, to: to.position)
        sceneView.scene.rootNode.addChildNode(lineNode)
        lineNodes.append(lineNode)
    }
    
    private func drawLine(from: SCNVector3, to: SCNVector3) -> SCNNode {
        // 直線のGeometryを作成する
        let source = SCNGeometrySource(vertices: [from, to])
        let element = SCNGeometryElement(data: Data.init(bytes: [0, 1]),
                                         primitiveType: .line,
                                         primitiveCount: 1,
                                         bytesPerIndex: 1)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        
        // 直線ノードの作成
        let node = SCNNode()
        node.geometry = geometry
        node.geometry?.materials.first?.diffuse.contents = UIColor.systemOrange
        return node
    }
    
    private func addDot(at hitResult : ARHitTestResult, color: UIColor, y: Float) {
        // dotのGeometryを作成
        let dotGeometry = SCNSphere(radius: CGFloat(dotRadius))
        let material = SCNMaterial()
        material.diffuse.contents = color
        
        dotGeometry.materials = [material]
        // dotノードの作成
        let dotNode = SCNNode(geometry: dotGeometry)
        // 座標の指定
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            y,
            hitResult.worldTransform.columns.3.z)
        // 子ノードを追加
        sceneView.scene.rootNode.addChildNode(dotNode)
        // 配列に追加
        dotNodes.append(dotNode)
    }
    
    private func addDistance(text: String, from: SCNNode, to: SCNNode){
        // textGeometryの生成
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        
        // fromとtoの座標の中央値を計算
        let x = (from.position.x + to.position.x) / 2.0
        let y = (from.position.y + to.position.y) / 2.0 + 0.01
        let z = (from.position.z + to.position.z) / 2.0
        textNode.position = SCNVector3(x, y, z)
        
        // scaleの設定
        let size = 0.001
        textNode.scale = SCNVector3(size, size, size)
        
        // 子ノードを追加
        sceneView.scene.rootNode.addChildNode(textNode)
        // 配列に追加
        textNodes.append(textNode)
    }
    
    private func calculateDistance(from: SCNNode, to: SCNNode) -> Float {
        let distance = sqrt(
            pow(to.position.x - from.position.x, 2) +
                pow(to.position.y - from.position.y, 2) +
                pow(to.position.z - from.position.z, 2)
        )
        //        distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        return distance
    }
    
    private func objectsAreTouched(start: SCNNode, end: SCNNode) -> Bool {
        let distance = calculateDistance(from: start, to: end)
        // 2点間の距離が(直径*1.2）以下になったら
        if distance <= (dotRadius*2)*1.2 {
            return true
        }
        return false
    }
    
    // MARK: - Prepare method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomPopup" {
            let roomImageViewController = segue.destination as! RoomImageViewController
            roomImageViewController.plotArray = plotArray
            roomImageViewController.distanceArray = distanceArray
        }
    }
    
}


// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    // 平面の表示
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            fatalError()
        }
        /*
         // ボールオブジェクトが追加されている場合に、平面は新たに表示しない
         if dotNodes != [] { return }
         */
        // 平面のインスタンスの生成
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        // 小要素に追加
        node.addChildNode(planeNode)
        
    }
    
    // 平面の大きさのアップデート
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            fatalError()
        }
        // 子ノードのfirstに格納されたものが平面でない場合 return
        guard let geometryPlaneNode = node.childNodes.first,
              let planeGeometry = geometryPlaneNode.geometry as? SCNPlane else {
            return
        }
        /*
         // ボールオブジェクトが追加されている場合に、平面オブジェクトを削除
         if dotNodes != [] {
         // remove node
         node.enumerateChildNodes { (node, stop) in
         node.removeFromParentNode() }
         }
         */
        // Geometry Update
        planeGeometry.width = CGFloat(planeAnchor.extent.x)
        planeGeometry.height = CGFloat(planeAnchor.extent.z)
        geometryPlaneNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
    }
    
    // 平面の生成
    private func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        // planeGeometryの作成
        let planeGeometry = SCNPlane(
            width: CGFloat(planeAnchor.extent.x),
            height: CGFloat(planeAnchor.extent.z))
        // 白　透過度0.5
        planeGeometry.materials.first?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        // planeノードの作成
        let planeNode = SCNNode()
        
        planeNode.geometry = planeGeometry
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        return planeNode
    }
    
}
