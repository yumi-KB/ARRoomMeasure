import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    //var dotNodes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        /// 特徴点の追加
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
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
}

    
    // MARK: - ARSCNViewDelegate
  
extension ViewController: ARSCNViewDelegate {
    
    // 平面の表示
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            fatalError()
        }
        //print("plane detected")
        
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
        guard let geometryPlaneNode = node.childNodes.first,
              let planeGeometry = geometryPlaneNode.geometry as? SCNPlane else {
            fatalError()
        }
        
        // Geometry Update
        planeGeometry.width = CGFloat(planeAnchor.extent.x)
        planeGeometry.height = CGFloat(planeAnchor.extent.z)
        geometryPlaneNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
    }
    
    // 平面の生成
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
 
        let plane = SCNPlane(
            width: CGFloat(planeAnchor.extent.x),
            height: CGFloat(planeAnchor.extent.z))
        // オレンジ　透過度０.7
        plane.materials.first?.diffuse.contents = UIColor.systemOrange.withAlphaComponent(0.7)
        let planeNode = SCNNode()

        planeNode.geometry = plane
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)

        return planeNode
    }
}
