import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes: [SCNNode] = []
    var lineNodes: [SCNNode] = []
    let dotRadius: Float = 0.01
    
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
        if dotNodes.count >= 20 {
            return
        }
        // 最初にタップした座標を取り出す
        guard let touch = touches.first else { return }
        // スクリーン座標に変換する
        let touchLocation = touch.location(in: sceneView)
        // タップされた位置の特徴点にあるARアンカーを探す
        let hitTestResults = sceneView.hitTest(touchLocation, types: .existingPlane)
        
        // ARアンカーがあればオブジェクトを置く
        if let hitResult = hitTestResults.first {
            // スタート地点のオブジェクトは オレンジ色
            // その他は 白色
            if dotNodes == [] {
                addDot(at: hitResult, color: .systemOrange)
            } else {
                addDot(at: hitResult, color: .white)
                
                /// オレンジ色の一番最初のドットオブジェクト
                let startObject = dotNodes[0]
                /// 最後に追加したドットオブジェクト
                let endObject = dotNodes[dotNodes.count-1]
                
                /* addLine */
                /// ひとつ前のオブジェクトの座標
                let fromPosition = dotNodes[dotNodes.count-2].position
                /// 最後に追加したオブジェクトの座標
                let endPosition = endObject.position
                // lineノードの作成
                let lineNode = drawLine(from: fromPosition, to: endPosition)
                sceneView.scene.rootNode.addChildNode(lineNode)
                lineNodes.append(lineNode)
                
                /* もしスタートオブジェクトと重なれば、終了 */
                if objectsAreTouched(start: startObject, end: endObject) {
                    print("finish")
                }
                 
            }
        }
    }
    
    @IBAction private func UndoAction(_ sender: UIButton) {
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
    
    private func addDot(at hitResult : ARHitTestResult, color: UIColor) {
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
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z)
        // 子ノードを追加
        sceneView.scene.rootNode.addChildNode(dotNode)
        // 配列に追加
        dotNodes.append(dotNode)
        
//        if dotNodes.count >= 2 {
//            calculate()
//        }
    }
    
    private func calculate(start: SCNNode, end: SCNNode) -> Float {
//        let start = dotNodes[0]
//        let end = dotNodes[1]

        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
                pow(end.position.y - start.position.y, 2) +
                pow(end.position.z - start.position.z, 2)
        )
        //        distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        return distance
    }
    
    private func objectsAreTouched(start: SCNNode, end: SCNNode) -> Bool {
        let distance = calculate(start: start, end: end)
        // 2点間の距離が(直径*1.2）以下になったら
        if distance <= (dotRadius*2)*1.2 {
            return true
        }
        return false
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
