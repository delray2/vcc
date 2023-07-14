import UIKit
import SceneKit
import ARKit
import SpriteKit
import AVFoundation
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import QuickLook
class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, CentralViewControllerDelegate, ColorViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UIDropInteractionDelegate, QLPreviewControllerDataSource {
    
    
    func didChangeColor(_ color: UIColor) {
        light1.color = color
    }
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var models: [URL?] = []
    var containerView = UIView()
    var isContainerViewVisible = true
    var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var lights:SCNLight!
    var houseNode:SCNNode!
    var tvNode:SCNNode!
    var lightNode:SCNNode!
    var cyllinder:SCNNode!
    let upButton = UIButton(type: .system)
    let downButton = UIButton(type: .system)
    let leftButton = UIButton(type: .system)
    let rightButton = UIButton(type: .system)
    var otherlightnode:SCNNode!
    var ambientLight:SCNLight!
    var transparentView = UIView()
    var cyllinder2:SCNNode!
    var cyllinder3:SCNNode!
    var light1Node:SCNNode!
    var light2Node:SCNNode!
    var light3Node:SCNNode!
    var light1:SCNLight!
    var light2:SCNLight!
    var light3:SCNLight!
    let cellIdentifier = "ModelCellIdentifier"
    
    var hue: CGFloat = 1.0
    var colorr = UIColor()
    var joystick: Joystick!
    var isJoystickActive: Bool = false
    var showMenu: UIButton!
    var showToolKit: UIButton!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        setupVideo()
        setupJoystick()
        setupScene()
        collectionView.register(ModelCell.self, forCellWithReuseIdentifier: "Cell")
        
        if let Modelurl = Bundle.main.url(forResource: "models", withExtension: nil) {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: Modelurl, includingPropertiesForKeys: nil)
                models = fileURLs.filter { $0.pathExtension == "scn" }
            } catch {
                print("Failed to load USDZ files: \(error)")
            }
            
        }
        let screenSize = UIScreen.main.bounds.size
       sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 300)
       collectionView.frame = CGRect(x: 43 , y: screenSize.height - 290, width: 325, height: 216)
    collectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5330038265)
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dragDelegate = self
        
        
        // Set up the SceneKit view
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue the cell using the correct identifier and cast it to ModelCell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ModelCell else {
            fatalError("Unable to dequeue ModelCell.")
        }
        
        let model = models[indexPath.row]
        
        
        
        guard let modelURL = model else { return cell }
        
        let modelEntity = try! SCNScene(url: modelURL, options: nil)
        
        cell.sceneView.scene = modelEntity
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    
    // MARK: - UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: models[indexPath.row]! as NSURL)
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    // MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSURL.self) { items in
            guard let url = items.first as? URL else { return }
            
            // Handle the dropped URL (e.g., load the scene from the URL)
            do {
                let scen = try SCNScene(url: url, options: nil)
                let node = scen.rootNode.childNode(withName: "root", recursively: true)
                // Add the scene to your scene view
                self.sceneView?.scene?.rootNode.addChildNode(node!)
            } catch {
                print("Failed to load SCNScene: \(error)")
            }
        }
    

        
        
    }
    func setupScene() {
        let destinationFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent("Export")
                url = destinationFolderURL.appendingPathComponent("Room.usdz")
                
        if let url = url {
            do {
                
                let scene = try SCNScene(url: url, options: nil)
                sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
                sceneView?.scene = scene
                sceneView?.scene?.background.contents = UIColor.black
                sceneView?.addInteraction(UIDropInteraction(delegate: self))
                view.addSubview(sceneView)
                
            } catch {
                print("Failed to load SCNScene: \(error)")
            }
            
            let cylinder = SCNCylinder(radius: 1.0, height: 2.0)
            
            // Create a node with the cylinder as its geometry
            cyllinder = SCNNode(geometry: cylinder)
            
            // Position the node in the scene
            cyllinder.position = SCNVector3(x: 0, y: 0, z: 0)
            
            // Add the node to the scene
            scene?.rootNode.addChildNode(cyllinder)
            cyllinder.name = "cyllinder"
            light1 = SCNLight()
            light1.type = .spot // Set the type of the light

            // Configure the light
            light1.color = UIColor.white // Set the color of the light
            light1.spotInnerAngle = 0
            light1.spotOuterAngle = 0// Set the intensity of the light

            // Create a node
            light1Node = SCNNode()

            // Add the light to the node
            light1Node.light = light1

            // Position the node in the scene
            light1Node.position = SCNVector3(x: 0, y: 10, z: 10)

            // Add the node to the scene
            cyllinder.addChildNode(light1Node)
           
            
            sceneView?.autoenablesDefaultLighting = true
            sceneView?.allowsCameraControl = true
         
            cameraNode = SCNNode()
            let camera = SCNCamera()
            cameraNode.camera = camera
            let root = sceneView.scene?.rootNode
            root?.addChildNode(cameraNode)
            upButton.backgroundColor = .blue
            upButton.setTitle("↑", for: .normal)
            upButton.addTarget(self, action: #selector(moveCameraUp), for: .touchUpInside)
            containerView.addSubview(upButton)
            downButton.backgroundColor = .blue
            downButton.setTitle("↓", for: .normal)
            downButton.addTarget(self, action: #selector(moveCameraDown), for: .touchUpInside)
            containerView.addSubview(downButton)
            
            leftButton.backgroundColor = .blue
            leftButton.setTitle("←", for: .normal)
            leftButton.addTarget(self, action: #selector(moveCameraLeft), for: .touchUpInside)
            containerView.addSubview(leftButton)
            upButton.frame = CGRect(x: 161, y: 55, width: 83, height: 33)
            downButton.frame = CGRect(x: 161, y: 206, width: 83, height: 33)
            leftButton.frame = CGRect(x: 86, y: 107, width: 50, height: 80)
            rightButton.frame = CGRect(x: 278, y: 107, width: 50, height: 80)
            rightButton.backgroundColor = .blue
            rightButton.setTitle("→", for: .normal)
            rightButton.addTarget(self, action: #selector(moveCameraRight), for: .touchUpInside)
            showMenu = UIButton(type: .system)
            showToolKit = UIButton(type: .system)
            containerView.addSubview(rightButton)
            
            containerView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 290)
            showMenu.frame = CGRect(x: view.bounds.width - 150, y: sceneView.frame.size.height - 70, width: 75, height: 35)
            showMenu.addTarget(self, action: #selector(onClickMenu), for: .touchUpInside)
            showMenu.backgroundColor = .blue
            showToolKit.frame = CGRect(x: view.bounds.width - 150, y: sceneView.frame.size.height - 50, width: 75, height: 35)
            showToolKit.addTarget(self, action: #selector(onClickToolKit), for: .touchUpInside)
            showToolKit.backgroundColor = .black
            sceneView?.addSubview(showToolKit)
            sceneView?.addSubview(showMenu)
            sceneView?.addSubview(collectionView)

        }
                    
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return url != nil ? 1 : 0
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url! as QLPreviewItem
        }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard let touchLocation = touches.first?.location(in: sceneView),
              let hitNode = sceneView?.hitTest(touchLocation, options: nil).first?.node,
              let nodeName = hitNode.name
        else {
            //No Node Has Been Tapped
            return
            
        }
        //Handle Event Here e.g. PerformSegue
        print(nodeName + "was clicked")
        if nodeName == "Wall0" {
            
            cyllinder = sceneView.scene?.rootNode.childNode(withName: "Wall0", recursively: true)
            cyllinder.addChildNode(light1Node)
            light1 = light1Node.light
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let centralVC = storyboard.instantiateViewController(withIdentifier: "CentralViewController") as? CentralViewController else {
                return
            }
            
            // Configure the presentation style
            centralVC.modalPresentationStyle = .popover
            
            // Configure the popover presentation controller
            if let popoverPresentationController = centralVC.popoverPresentationController {
                popoverPresentationController.permittedArrowDirections = [.up, .down, .left, .right]
                popoverPresentationController.sourceView = sceneView
                popoverPresentationController.sourceRect = CGRect(x: touchLocation.x, y: touchLocation.y, width: 0, height: 0)
                popoverPresentationController.delegate = self
                centralVC.delegate = self
                
            }
            
            
            // Present the popover
            self.present(centralVC, animated: true, completion: nil)
            webrequest()
            cyllinderOne()
        }
        
        
        
        if nodeName == "cyllinder2" {
            cyllinder2 = sceneView.scene?.rootNode.childNode(withName: "cyllinder2", recursively: true)
            
            light2Node = cyllinder2.childNode(withName: "light2", recursively: true)
            light1 = lightNode?.light
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let colorVC = storyboard.instantiateViewController(withIdentifier: "ColorViewController") as? ColorViewController else {
                return
            }
            
            // Configure the presentation style
            colorVC.modalPresentationStyle = .popover
            
            // Configure the popover presentation controller
            if let popoverPresentationController = colorVC.popoverPresentationController {
                popoverPresentationController.permittedArrowDirections = [.up, .down, .left, .right]
                popoverPresentationController.sourceView = sceneView
                popoverPresentationController.sourceRect = CGRect(x: touchLocation.x, y: touchLocation.y, width: 0, height: 0)
                popoverPresentationController.delegate = self
                colorVC.delegate = self
                webrequest2()
                CyllinderTwo()
                
            }
            if nodeName == "cyllinder3" {
                
                webrequest3()
                CyllinderThree()
                
            }
           
        }
    }
    
    
    
    func setupNodes() {
        guard let sceneView = sceneView else { return }
        cyllinder = sceneView.scene?.rootNode.childNode(withName: "cyllinder1", recursively: true)
        cyllinder2 = sceneView.scene?.rootNode.childNode(withName: "cyllinder2", recursively: true)
        cyllinder3 = sceneView.scene?.rootNode.childNode(withName: "cyllinder3", recursively: true)
        
        
    }

    
    
    
    
        
        func setupVideo() {
            
            // A SpriteKit scene to contain the SpriteKit video node
            let spriteKitScene = SKScene(size: CGSize(width: view.bounds.width, height: view.bounds.height))
            spriteKitScene.scaleMode = .aspectFit
            
            // Create a video player, which will be responsible for the playback of the video material
            let videoUrl = Bundle.main.url(forResource: "home", withExtension: "mov")!
            let videoPlayer = AVPlayer(url: videoUrl)
            
            // Create the SpriteKit video node, containing the video player
            let videoSpriteKitNode = SKVideoNode(avPlayer: videoPlayer)
            videoSpriteKitNode.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
            videoSpriteKitNode.size = spriteKitScene.size
            videoSpriteKitNode.yScale = -1.0
            videoSpriteKitNode.play()
            spriteKitScene.addChild(videoSpriteKitNode)
            
            
            // Create a SceneKit plane and add the SpriteKit scene as its material
            let screen = SCNPlane(width: CGFloat(2), height: CGFloat(1.5))
            screen.firstMaterial?.diffuse.contents = spriteKitScene
            let screenNode = SCNNode(geometry: screen)
            
            scene?.rootNode.addChildNode(screenNode)
            screenNode.position = SCNVector3(x: 0.661, y: 0, z: 2.465)
            screenNode.eulerAngles = SCNVector3(x: -59.5, y: 0, z: 0)
            screenNode.geometry?.firstMaterial?.selfIllumination.intensity = 5
            screenNode.geometry?.firstMaterial?.selfIllumination.contents = SKColor(white: 100, alpha: 1)
            
        }
    func setupJoystick() {
        let joystickSize: CGFloat = 100.0
        let joystickFrame = CGRect(x: (self.containerView.frame.size.width - joystickSize) / 2.0,
                                   y: (self.containerView.frame.size.height - joystickSize) / 2.0,
                                   width: joystickSize,
                                   height: joystickSize)
        joystick = Joystick(frame: joystickFrame, neutralPoint: CGPoint(x: joystickSize/2, y: joystickSize/2))
        joystick.viewController = self
        self.containerView.addSubview(joystick)
    }

        // This method should be called when the joystick handle is moved
    func joystickMoved(to position: CGPoint) {
        if isJoystickActive {
            let dx = position.x - joystick.neutralPoint.x
            let dy = position.y - joystick.neutralPoint.y
            cameraNode = sceneView.scene?.rootNode.childNode(withName: "camera", recursively: true)
            
            // Reduce the values you multiply dx and dy by to decrease the speed of rotation
            let angleX = Float(dy / 100.0) * Float.pi / 180.0
            let angleY = Float(dx / 100.0) * Float.pi / 180.0

            let actionX = SCNAction.rotate(by: CGFloat(angleX), around: SCNVector3(1, 0, 0), duration: 0.1) // small duration for slow, smooth rotation
            let actionY = SCNAction.rotate(by: CGFloat(angleY), around: SCNVector3(0, 1, 0), duration: 0.1)

            cameraNode.runAction(actionX)
            cameraNode.runAction(actionY)
        }
    }
        
        
        
        func cyllinderOne() {
            let actionA = SCNAction.customAction(duration: 0.5) { (node, elapsedTime) in
                self.cyllinder.scale = SCNVector3(x: 0.022, y: 0.022, z: 0.022)
            }
            let actionB = SCNAction.customAction(duration: 0.5) { (node, elapsedTime) in
                self.cyllinder.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
            }
            
            let sequence = SCNAction.sequence([actionA, actionB])
            
            cyllinder.runAction(sequence)
            
            
            SCNTransaction.begin()
            SCNTransaction
                .animationDuration = 1.0
            cyllinder.opacity = CGFloat(1.0)
            cyllinder.geometry?.firstMaterial?.diffuse.intensity = 2
            light1.spotOuterAngle = CGFloat(22.07)
            light1.spotInnerAngle = CGFloat(6.091)
            light1.intensity = CGFloat(390.61)
            
            
            
            SCNTransaction.commit()
        }
        func CyllinderTwo() {
            let actionA = SCNAction.customAction(duration: 0.5) { (node, elapsedTime) in
                self.cyllinder2.scale = SCNVector3(x: 0.02, y: 0.022, z: 0.22)
            }
            let actionB = SCNAction.customAction(duration: 0.5) { (node, elapsedTime) in
                self.cyllinder2.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
            }
            
            let sequence = SCNAction.sequence([actionA, actionB])
            light2Node = sceneView.scene?.rootNode.childNode(withName: "light2", recursively: true)
            light2 = light2Node.light
            cyllinder2.runAction(sequence)
            SCNTransaction.begin()
            SCNTransaction
                .animationDuration = 1.0
            cyllinder2.opacity = CGFloat(1.0)
            cyllinder2.geometry?.firstMaterial?.diffuse.intensity = 2
            light2.spotOuterAngle = CGFloat(22.07)
            light2.spotInnerAngle = CGFloat(6.091)
            light2.intensity = CGFloat(390.61)
        }
        
        func CyllinderThree() {
            let actionA = SCNAction.customAction(duration: 0.5) { (node, elapsedTime) in
                self.cyllinder3.scale = SCNVector3(x: 0.04, y: 0.04, z: 0.04)
            }
            let actionB = SCNAction.customAction(duration: 0.5) { (node, elapsedTime) in
                self.cyllinder3.scale = SCNVector3(x: 0.049, y: 0.049, z: 0.049)
            }
            
            let sequence = SCNAction.sequence([actionA, actionB])
            light3Node = sceneView.scene?.rootNode.childNode(withName: "light3", recursively: true)
            light3 = light3Node.light
            
            cyllinder3.runAction(sequence)
            SCNTransaction.begin()
            SCNTransaction
                .animationDuration = 1.0
            cyllinder3.opacity = CGFloat(1.0)
            cyllinder3.geometry?.firstMaterial?.diffuse.intensity = 2
            
            light3.spotOuterAngle = CGFloat(22.07)
            light3.spotInnerAngle = CGFloat(6.091)
            light3.intensity = CGFloat(390.61)
        }
        
        func webrequest() {
            
            
            var request = URLRequest(url: URL(string: "https://maker.ifttt.com/trigger/Button/json/with/key/PYdLLZY6FPbgKa1IAOCrJ")!,timeoutInterval: Double.infinity)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                print(String(data: data, encoding: .utf8)!)
            }
            
            task.resume()
            
            
        }
        func webrequest2() {
            
            
            var request = URLRequest(url: URL(string: "https://maker.ifttt.com/trigger/Button/json/with/key/PYdLLZY6FPbgKa1IAOCrJ")!,timeoutInterval: Double.infinity)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                print(String(data: data, encoding: .utf8)!)
            }
            
            task.resume()
            
            
        }
        
        func webrequest3() {
            
            
            var request = URLRequest(url: URL(string: "https://maker.ifttt.com/trigger/Button/json/with/key/PYdLLZY6FPbgKa1IAOCrJ")!,timeoutInterval: Double.infinity)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                print(String(data: data, encoding: .utf8)!)
            }
            
            task.resume()
            
            
        }
        
        
    

    
   @objc func onClickMenu(_ sender: Any) {
        sceneView.allowsCameraControl = false
        
       
        let window = self.view.window
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        
        let screenSize = UIScreen.main.bounds.size
        
        containerView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 290)
        containerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        transparentView.addSubview(containerView)
       
       
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 1
            self.containerView.frame = CGRect(x: 0, y: screenSize.height - 290, width: screenSize.width, height: 290)
            self.sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 290)
            self.showMenu.frame = CGRect(x: screenSize.width - 150, y: screenSize.height - 360, width: 75, height: 35)
        }, completion: nil)
        
    }
    
    @objc func onClickTransparentView() {
        sceneView.allowsCameraControl = true
        
        
        let screenSize = UIScreen.main.bounds.size

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.containerView.frame = CGRect(x: 0, y: screenSize.height + 290, width: screenSize.width, height: 290)
            self.sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            self.showMenu.frame = CGRect(x: screenSize.width - 150, y: screenSize.height - 70, width: 75, height: 35)
        }, completion: nil)
    }
    
    @objc func onClickToolKit(_ sender: Any) {
         sceneView.allowsCameraControl = false
         
        
         let window = self.view.window
        
         window?.addSubview(collectionView)
         
         let screenSize = UIScreen.main.bounds.size
        self.sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 300)
        self.collectionView.frame = CGRect(x: 43 , y: screenSize.height - 290, width: 325, height: 216)
         collectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5330038265)
         
        self.view.addSubview(collectionView)
        
        
         
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparent1View))
        self.view.addGestureRecognizer(tapGesture)
         
     
         
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
           
             self.collectionView.frame = CGRect(x: 43 , y: screenSize.height - 290, width: 325, height: 216)
             self.sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 300)
             self.showToolKit.frame = CGRect(x: screenSize.width - 150, y: screenSize.height - 360, width: 75, height: 35)
         }, completion: nil)
         
     }
     
     @objc func onClickTransparent1View() {
         sceneView.allowsCameraControl = true
         
         
         let screenSize = UIScreen.main.bounds.size

         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
             self.transparentView.alpha = 0
             self.collectionView.frame = CGRect(x: 43 , y: screenSize.height + 290, width: 325, height: 216)
             self.sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
             self.showToolKit.frame = CGRect(x: screenSize.width - 150, y: screenSize.height - 90, width: 75, height: 35)
         }, completion: nil)
     }
     
         @objc func moveCameraDown() {
        
        let moveCamDown = SCNAction.move(by: SCNVector3(x: 0, y: -1, z: 0), duration: 1.0)
        cameraNode?.runAction(moveCamDown)
    }
    
    @objc func moveCameraUp() {
        let moveCamUp = SCNAction.move(by: SCNVector3(x: 0, y: +1, z: 0), duration: 1.0)
        cameraNode.runAction(moveCamUp)
    }
    @objc func moveCameraLeft() {
        let moveCamLeft = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 1.0)
        cameraNode.runAction(moveCamLeft)
    }
    
    @objc func moveCameraRight() {
        let moveCamRight = SCNAction.move(by: SCNVector3(x: +1, y: 0, z: 0), duration: 1.0)
        cameraNode.runAction(moveCamRight)
    }
}

