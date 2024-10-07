//
//  Model.swift
//  3D 2048
//
//  Created by Andrew Palombo on 08/01/2021.
//

import UIKit
import RealityKit
import Combine

// Contains everything needed to display models
// Use of Combine framework enables content to be loaded asynchronously (doesn't freeze up UI)
class Model {
	var modelName: String
	var modelEntity: ModelEntity?
	
	private var cancellable: AnyCancellable? = nil
	
	init(modelName: String) {
		self.modelName = modelName
		
		// Asynchronously load modelEntity
		let filename = modelName + ".usdz"
		self.cancellable = ModelEntity.loadModelAsync(named: filename)
			.sink(receiveCompletion: { (loadCompletion) in
				// Handle error
				print("DEBUG: Unable to load modelEntity for modelName: \(self.modelName)")
			}, receiveValue: { (modelEntity) in
				// Get modelEntity
				self.modelEntity = modelEntity
				print("DEBUG: Successfully loaded modelEntity for modelName: \(self.modelName)")
			})
	}
}
