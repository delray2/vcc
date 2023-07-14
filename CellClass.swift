//
//  CellClass.swift
//  ViewController
//
//  Created by Delray on 7/13/23.
//

import RealityKit
import UIKit
import ARKit
import SceneKit

class ModelCell: UICollectionViewCell {
    var sceneView: SCNView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sceneView = SCNView(frame: .zero)
        contentView.addSubview(sceneView)
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: contentView.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sceneView = SCNView(frame: .zero)
        contentView.addSubview(sceneView)
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: contentView.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
