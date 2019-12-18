//
//  ViewController.swift
//  AR Drawing
//
//  Created by Anshul Goyal on 21/10/19.
//  Copyright © 2019 Anshul Goyal. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self // this is the statement required to call delegate functions
    }

    //note that this is a delegate function which renders & updates the SCNKit content in our AR session real time
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        print("rendering")
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        // multiply each direction by 5 if we want the drawing to be done 5 metres away from the camera
        let orientation = SCNVector3(-transform.m31 * 5, -transform.m32 * 5, -transform.m33 * 5)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        // location variable IS exactly the position of the camera, but since we want to add a node in front of our phone camera, we calculate the orientation value which ranges from (-1,+1) and add it to the location variable to get a position in front of the camera. Orientation vector takes into account the direction of the normal of our camera in the scene (+1 x-coordinate if pointing exactly to the right, -1 if exactly left and so on).
        // NOTE : the orientation vector is simply a unit-vector (magnitude = 1) of direction, example : SCNVector3(x: -0.03430799, y: -0.95320106, z: -0.3003843) : whose magnitude sqrt(x^2 + y^2 + z^2) == 1 , so if we want to place a node 7 meters away from our camera in the direction of the normal of our camera, then we simply multiply the orientation vector by a value of 7, and add the orientation vector to the location vector of our camera.
        let frontOfCamera = orientation + location
        print(orientation)
        
        DispatchQueue.main.async {
            if self.draw.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = frontOfCamera
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
            }
            else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "drawPointer"
                pointer.position = frontOfCamera
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "drawPointer" {
                        node.removeFromParentNode()
                    }
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
            }
        }

//        print("orientation : ", orientation.x, orientation.y, orientation.z)
//        print("location : ", location.x, location.y, location.z)
        
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

