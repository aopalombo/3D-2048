//
//  FocusARView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 09/01/2021.
//

import RealityKit
import FocusEntity
import Combine
import ARKit
import UIKit

class FocusARView: ARView {
	var focusEntity: FocusEntity?
	required init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		self.setupConfig()
		self.focusEntity = FocusEntity(on: self, focus: .classic)
		//    self.focusEntity = FocusEntity(on: self, style: .colored(onColor: .red, offColor: .blue, nonTrackingColor: .orange))
	}
	
	func setupConfig() {
		let config = ARWorldTrackingConfiguration()
		config.planeDetection = [.horizontal, .vertical]
		
		// Add support for iPhone 12 LIDAR
		if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
			config.sceneReconstruction = .mesh
		}
		
		session.run(config, options: [])
	}
	
	@objc required dynamic init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension FocusARView: FocusEntityDelegate {
	func toTrackingState() {
		print("tracking")
	}
	func toInitializingState() {
		print("initializing")
	}
	func hide() {
		self.focusEntity?.isEnabled = false
	}
	func show() {
		self.focusEntity?.isEnabled = true
	}
}
