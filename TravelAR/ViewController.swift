//
//  ViewController.swift
//  TravelAR
//
//  Created by Utkarsh Pandey on 9/17/17.
//  Copyright © 2017 Utkarsh Pandey. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    let bubbleDepth : Float = 0.03 // the 'depth' of 3D text
    var flightData:[FlightData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        print("Count is \(flightData.count)")
        addEndPointNodes()
        addEdges()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func addEndPointNodes() {
        
        //let zCoords = randomFloat(min: -2, max: -0.2)
        //        let cubeNode = SCNNode(geometry: SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0))
        //        let cc = getCameraCoordinates(sceneView: sceneView)
        //        cubeNode.position = SCNVector3(cc.x, cc.y, cc.z)
        //        sceneView.scene.rootNode.addChildNode(cubeNode)
        //
        if flightData.count == 0 {
            print ("Count is zero"); return
        }
        let orgCity = flightData[0].flightOrig
        let destCity = flightData[0].flightDest
        let startNode = createNewBubbleParentNode("Start City: " + orgCity)
        let endNode = createNewBubbleParentNode("End City:" + destCity)
        startNode.position = SCNVector3(-0.6, 0, 0)
        endNode.position = SCNVector3(0.6, 0, 0)
        sceneView.scene.rootNode.addChildNode(startNode)
        sceneView.scene.rootNode.addChildNode(endNode)
    }
    
    func addEdges(){
        
        if flightData.count == 0 {
            print ("Count is zero"); return
        }
        
//        let edgeMultiplier = 2
        
        for i in 0..<5{
            let fName = flightData[i].flightName
            let fPrice = flightData[i].flightTotalPrice
            let edgeBox = SCNBox(width: 1.2, height: 0.01, length: 0.01, chamferRadius: 0)
            if i == 0 {
                edgeBox.firstMaterial?.diffuse.contents = UIColor.blue
            } else if i == 1 {
                edgeBox.firstMaterial?.diffuse.contents = UIColor.green
            }
            else if i == 2{
                edgeBox.firstMaterial?.diffuse.contents = UIColor.yellow
            }
            else if i == 3 {
                edgeBox.firstMaterial?.diffuse.contents = UIColor.purple
            }
            else if i == 4 {
                edgeBox.firstMaterial?.diffuse.contents = UIColor.red
            }
 
            
            let edgeNode = SCNNode(geometry: edgeBox)
            edgeNode.position = SCNVector3(0, 0, Double(i)/5)
            let priceNode = createNewBubbleParentNode(fPrice)
            let nameNode = createNewBubbleParentNode(fName)
            priceNode.position = SCNVector3(0, 0.05, Double(i)/5)
            edgeNode.addChildNode(priceNode)
            nameNode.position = SCNVector3(0, 0.15, Double(i)/5)
            edgeNode.addChildNode(nameNode)
            sceneView.scene.rootNode.addChildNode(edgeNode)
        }
        
        
        

//        // Define a 2D path for the parabola
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addQuadCurve(to: CGPoint(x: 10, y: 0), controlPoint: CGPoint(x: 5.0, y: 20.0))
//        path.addLine(to: CGPoint(x: 9.9, y: 0))
//        path.addQuadCurve(to: CGPoint(x: 0.1, y: 0), controlPoint: CGPoint(x: 5.0, y: 19.8))
//
//        // Tweak for a smoother shape (lower is smoother)
//        path.flatness = 0.25
//
//        // Make a 3D extruded shape from the path
//        let shape = SCNShape(path: path, extrusionDepth: 10)
//        shape.firstMaterial?.diffuse.contents = UIColor.blue
//
//        // And place it in the scene
//        let shapeNode = SCNNode(geometry: shape)
//        shapeNode.pivot = SCNMatrix4MakeTranslation(50, 0, 0)
//        shapeNode.eulerAngles.y = Float(-Double.pi/4)
//        sceneView.scene.rootNode.addChildNode(shapeNode)
    }
    
    struct CameraCoordinates{
        var x = Float()
        var y = Float()
        var z = Float()
    }
    
    func getCameraCoordinates(sceneView: ARSCNView) -> CameraCoordinates{
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix : cameraTransform!)
        
        var cc = CameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        
        return cc
    }
    
    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // BUBBLE-TEXT
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        var font = UIFont(name: "Futura", size: 0.15)
        font = font?.withTraits(traits: .traitBold)
        bubble.font = font
        bubble.alignmentMode = kCAAlignmentCenter
        bubble.firstMaterial?.diffuse.contents = UIColor.orange
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        // bubble.flatness // setting this too low can cause crashes.
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        // BUBBLE NODE
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.3, 0.3, 0.3)
        
        // CENTRE POINT NODE
        let sphere = SCNSphere(radius: 0.01)
        sphere.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode(geometry: sphere)
        
        // BUBBLE PARENT NODE
        let bubbleNodeParent = SCNNode()
        bubbleNodeParent.addChildNode(bubbleNode)
        bubbleNodeParent.addChildNode(sphereNode)
        bubbleNodeParent.constraints = [billboardConstraint]
        
        return bubbleNodeParent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}

