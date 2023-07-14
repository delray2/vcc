import UIKit
import SceneKit

class Joystick: UIView {
    var backgroundCircle: UIView!
    var handle: UIView!
    
    let handleRadius: CGFloat = 25.0
    let neutralPoint: CGPoint
    
    weak var viewController: ViewController?
    
    init(frame: CGRect, neutralPoint: CGPoint) {
        self.neutralPoint = neutralPoint
        super.init(frame: frame)
        
        self.backgroundCircle = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: frame.size.height))
        self.backgroundCircle.layer.cornerRadius = frame.size.width/2
        self.backgroundCircle.backgroundColor = UIColor.white
        self.addSubview(self.backgroundCircle)
        
        self.handle = UIView(frame: CGRect(x: 0, y: 0, width: handleRadius * 2, height: handleRadius * 2))
        self.handle.center = neutralPoint
        self.handle.layer.cornerRadius = handleRadius
        self.handle.backgroundColor = UIColor.darkGray
        self.addSubview(self.handle)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.handle.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let distanceFromCenter = sqrt(pow(location.x - neutralPoint.x, 2) + pow(location.y - neutralPoint.y, 2))
        if distanceFromCenter < (self.frame.width / 2) {
            self.handle.center = location
            
            
            // Invoke joystickMoved method in viewController
            viewController?.joystickMoved(to: location)
            viewController?.isJoystickActive = true
        }
        if gesture.state == .ended || gesture.state == .cancelled {
            UIView.animate(withDuration: 0.2) {
                self.handle.center = self.neutralPoint
            }
            (self.superview as? ViewController)?.isJoystickActive = false
        }
    }
}
