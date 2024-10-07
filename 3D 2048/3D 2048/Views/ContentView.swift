//
//  ContentView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 08/01/2021.
//

import SwiftUI
import RealityKit
import AVFoundation

struct ContentView : View {
	@EnvironmentObject var game: Game
	
	@State private var inPlayMode = false
	@State private var focusEntityNeeded = false
	@State private var placeGrid = false
//	@State private var tilesForTranslation = [(start: Coordinates, finish: Coordinates)]()
//	@State private var tilesForPlacement = [(tileName: String, coordinates: Coordinates)]()
//	@State private var tilesForRemoval = [Coordinates]()
//	@State private var tilePositions = [(tileId: String, coordinates: Coordinates?)]()
	@State private var resetGameAr = false
	
	// Default start value = 0
	@State private var highScore = UserDefaults.standard.integer(forKey: "HighScore") {
		didSet {
			UserDefaults.standard.set(highScore, forKey: "HighScore")
		}
	}
	@State private var highestTile = UserDefaults.standard.integer(forKey: "HighestTile") {
		didSet {
			UserDefaults.standard.set(highestTile, forKey: "HighestTile")
		}
	}
	@State private var gamesWon = UserDefaults.standard.integer(forKey: "GamesWon") {
		didSet {
			UserDefaults.standard.set(gamesWon, forKey: "GamesWon")
		}
	}
	
	@State private var launchedBefore = UserDefaults.standard.bool(forKey: "LaunchedBefore")
	
	private var models: [String: Model] = {
		// Get filenames dynamically
		let fileManager = FileManager.default
		
		guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
			return [:]
		}
		
		var models = [String: Model]()
		for filename in files where filename.hasSuffix("usdz") {
			let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
			let model = Model(modelName: modelName)
			
			models[modelName] = model
		}
		
		return models
	}()
	
	private var cameraAccessAllowed: Bool {
		if AVCaptureDevice.authorizationStatus(for: .video) ==  .denied {
			return false
		} else {
			return true
		}
	}
	
	init() {
		// By accessing the contents of the computed property 'models', the modelEntity's are also loaded on app launch - ready for use.
		for (_, model) in self.models {
			print("DEBUG: loading \(model.modelName)")
		}
	}
	
    var body: some View {
		ZStack(alignment: .center) {
			if launchedBefore {
				if cameraAccessAllowed {
					ARViewContainer(inPlayMode: self.$inPlayMode, focusEntityNeeded: self.$focusEntityNeeded, placeGrid: self.$placeGrid, resetGameAr: self.$resetGameAr, models: self.models).edgesIgnoringSafeArea(.all)
					
					if self.inPlayMode {
						GameView(inPlayMode: self.$inPlayMode, focusEntityNeeded: self.$focusEntityNeeded, placeGrid: self.$placeGrid, resetGameAr: self.$resetGameAr, highScore: $highScore, highestTile: $highestTile, gamesWon: $gamesWon, models: self.models)
					} else {
						MenuView(inPlayMode: self.$inPlayMode, focusEntityNeeded: self.$focusEntityNeeded, highScore: $highScore, highestTile: $highestTile, gamesWon: $gamesWon, launchedBefore: $launchedBefore).edgesIgnoringSafeArea(.all)
					}
				} else {
					CameraAccessDeniedView()
				}
			} else {
				HowToPlayView(launchedBefore: $launchedBefore)
			}
		}
    }
}

struct ARViewContainer: UIViewRepresentable {
	@EnvironmentObject var game: Game
	
	@Binding var inPlayMode: Bool
	@Binding var focusEntityNeeded: Bool
	@Binding var placeGrid: Bool
//	@Binding var tilesForTranslation: [(start: Coordinates, finish: Coordinates)]
//	@Binding var tilesForPlacement: [(tileName: String, coordinates: Coordinates)]
//	@Binding var tilesForRemoval: [Coordinates]
//	@Binding var tilePositions: [(tileId: String, coordinates: Coordinates?)]
	@Binding var resetGameAr: Bool
	
	var models: [String: Model]
	
	
    func makeUIView(context: Context) -> FocusARView {
        
		FocusARView(frame: .zero)//ARView(frame: .zero)
        
    }
    
	// MARK: Update UI
    func updateUIView(_ uiView: FocusARView, context: Context) {
		// When updating the AR view:
		// Enable/disable the focus entity
		if self.focusEntityNeeded {
			uiView.show()
		} else {
			uiView.hide()
		}
		
		// Remove all AR objects, when menu is selected
		if !self.inPlayMode {
			for anchor in uiView.scene.anchors where anchor.name != "FocusEntity" {
				uiView.scene.removeAnchor(anchor)
			}
		}
		
		
		
		// Place the grid
		if self.placeGrid {
			let model = models["Frame"]!
			// May not exist yet as it is loaded asynchronously
			if let modelEntity = model.modelEntity {
				print("DUBUG: adding model to scene - \(model.modelName)")
				
				let anchorEntity = AnchorEntity(plane: .any)
				anchorEntity.name = "Game"
				modelEntity.name = "Frame"
				anchorEntity.addChild(modelEntity)
				
				uiView.scene.addAnchor(anchorEntity)
				
			} else {
				print("DEBUG: unable to load modelEntity for \(model.modelName)")
			}
			
			// Once object has been added, it does not need to be added again
			// Add this to queue to avoid conflicting messages
			DispatchQueue.main.async {
				self.placeGrid = false
			}
		}
		
		// MARK: Placing Tiles:
		if let gameAnchorEntity = uiView.scene.findEntity(named: "Game") {
//			let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
			// Remove all tiles
			DispatchQueue.main.async {
				for childEntity in gameAnchorEntity.children where childEntity.name != "Frame" {
					gameAnchorEntity.removeChild(childEntity)
				}
			}
			
			DispatchQueue.main.async {
				// Add tiles
				for x in 0 ... 2 {
					for y in 0 ... 2 {
						for z in 0 ... 2 {
							let value = game.matrix[x][y][z]
							if value != 0 {
								let model = models[("Tile" + String(value))]!
								if let modelEntity = model.modelEntity {
									print("DUBUG: adding model to scene - \(model.modelName)")
									
									// Clone the model entity to allow multiple simultaneous occurrences of the same tile value
									let clonedModelEntity = modelEntity.clone(recursive: true)

									// In order for entities to be placed relative to each other, they must all be child entities of the same
									// anchor entity.
	//								let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
									let centrePosition = gameAnchorEntity.findEntity(named: "Frame")!.position

									// Find tile position
									var zeroPosition = centrePosition
									zeroPosition.x -= 0.05
									zeroPosition.y +=  0.005
									zeroPosition.z -= 0.05

									var finalPosition = zeroPosition
									finalPosition.x += Float(x) * 5.0 * 0.01
									finalPosition.y += Float(y) * 5.0 * 0.01
									finalPosition.z += Float(z) * 5.0 * 0.01
									
									// Add relevant data to tile entity
									clonedModelEntity.position = finalPosition
	//								clonedModelEntity.name = tileForFirstPlacement.tileId
									
									// Add tile to anchor
									gameAnchorEntity.addChild(clonedModelEntity)
								}
							}
						}
					}
				}
			}
			
		}
		DispatchQueue.main.async {
			game.updateView = false
		}
		
		// not being used
		if false {
			// Translation
			for tileForTranslation in game.tilesForTranslation {
				let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
				let currentTileEntity = gameAnchorEntity.findEntity(named: tileForTranslation.tileId)!
	//			currentTileEntity.move(to: <#T##Transform#>, relativeTo: <#T##Entity?#>, duration: <#T##TimeInterval#>, timingFunction: <#T##AnimationTimingFunction#>)
				
				// Find new tile position
				let centrePosition = gameAnchorEntity.findEntity(named: "Frame")!.position
				
				var zeroPosition = centrePosition
				zeroPosition.x -= 0.05
				zeroPosition.y +=  0.005
				zeroPosition.z -= 0.05
				
				var finalPosition = zeroPosition
				finalPosition.x += Float(tileForTranslation.finish.x) * 5.0 * 0.01
				finalPosition.y += Float(tileForTranslation.finish.y) * 5.0 * 0.01
				finalPosition.z += Float(tileForTranslation.finish.z) * 5.0 * 0.01
				
				// Translate tile
				currentTileEntity.position = finalPosition
			}
			DispatchQueue.main.async {
				game.tilesForTranslation = []
			}
			
			// Removal
			for tileForRemoval in game.tilesForRemoval {
				let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
				let currentTileEntity = gameAnchorEntity.findEntity(named: tileForRemoval)!
				gameAnchorEntity.removeChild(currentTileEntity)
			}
			DispatchQueue.main.async {
				game.tilesForRemoval = []
			}
			
			// First placement
			for tileForFirstPlacement in game.tilesForFirstPlacement {
				let model = models[tileForFirstPlacement.tileName]!
				
				if let modelEntity = model.modelEntity {
					print("DUBUG: adding model to scene - \(model.modelName)")
					
					// Clone the model entity to allow multiple simultaneous occurrences of the same tile value
					let clonedModelEntity = modelEntity.clone(recursive: true)

					// In order for entities to be placed relative to each other, they must all be child entities of the same
					// anchor entity.
					let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
					let centrePosition = gameAnchorEntity.findEntity(named: "Frame")!.position

					// Find tile position
					var zeroPosition = centrePosition
					zeroPosition.x -= 0.05
					zeroPosition.y +=  0.005
					zeroPosition.z -= 0.05

					var finalPosition = zeroPosition
					finalPosition.x += Float(tileForFirstPlacement.coordinates.x) * 5.0 * 0.01
					finalPosition.y += Float(tileForFirstPlacement.coordinates.y) * 5.0 * 0.01
					finalPosition.z += Float(tileForFirstPlacement.coordinates.z) * 5.0 * 0.01
					
					// Add relevant data to tile entity
					clonedModelEntity.position = finalPosition
					clonedModelEntity.name = tileForFirstPlacement.tileId
					
					// Add tile to anchor
					gameAnchorEntity.addChild(clonedModelEntity)
					
				} else {
					print("DEBUG: unable to load modelEntity for \(model.modelName)")
				}
			}
			DispatchQueue.main.async {
				game.tilesForFirstPlacement = []
			}
			
			// Second placement
			for tileForSecondPlacement in game.tilesForSecondPlacement {
				let model = models[tileForSecondPlacement.tileName]!
				
				if let modelEntity = model.modelEntity {
					print("DUBUG: adding model to scene - \(model.modelName)")
					
					// Clone the model entity to allow multiple simultaneous occurrences of the same tile value
					let clonedModelEntity = modelEntity.clone(recursive: true)

					// In order for entities to be placed relative to each other, they must all be child entities of the same
					// anchor entity.
					let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
					let centrePosition = gameAnchorEntity.findEntity(named: "Frame")!.position

					// Find tile position
					var zeroPosition = centrePosition
					zeroPosition.x -= 0.05
					zeroPosition.y +=  0.005
					zeroPosition.z -= 0.05

					var finalPosition = zeroPosition
					finalPosition.x += Float(tileForSecondPlacement.coordinates.x) * 5.0 * 0.01
					finalPosition.y += Float(tileForSecondPlacement.coordinates.y) * 5.0 * 0.01
					finalPosition.z += Float(tileForSecondPlacement.coordinates.z) * 5.0 * 0.01
					
					// Add relevant data to tile entity
					clonedModelEntity.position = finalPosition
					clonedModelEntity.name = tileForSecondPlacement.tileId
					
					// Add tile to anchor
					gameAnchorEntity.addChild(clonedModelEntity)
					
				} else {
					print("DEBUG: unable to load modelEntity for \(model.modelName)")
				}
			}
			DispatchQueue.main.async {
				game.tilesForSecondPlacement = []
			}
		}
//		DispatchQueue.main.async {
//			game.updateView = false
//		}
		
		
//		DispatchQueue.main.async {
//			// TRANSLATE TILES
////			print(self.game.tilesForTranslation)
//			for index in 0 ..< self.game.tilesForTranslation.count {
//				let tile = self.game.tilesForTranslation[index]
//				// Find tileId
//				var tileId: String?
//				for tilePosition in self.game.tilePositions {
//					if tilePosition.coordinates == tile.start {
//						tileId = tilePosition.tileId
//						break
//					}
//				}
//
//				// Get access to entities needed for translation
//				let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
//				print("tilePositions: \(self.game.tilePositions)")
//				print("tilesForTranslation: \(self.game.tilesForTranslation)")
//				print("tilesForRemoval: \(self.game.tilesForRemoval)")
//				print("tilesForPlacement: \(self.game.tilesForPlacement)")
//				let currentTileEntity = gameAnchorEntity.findEntity(named: tileId!)!
//
//				// Find new tile position
//				let centrePosition = gameAnchorEntity.findEntity(named: "Frame")!.position
//
//				var zeroPosition = centrePosition
//				zeroPosition.x -= 0.05
//				zeroPosition.y +=  0.005
//				zeroPosition.z -= 0.05
//
//				var finalPosition = zeroPosition
//				finalPosition.x += Float(tile.finish.x) * 5.0 * 0.01
//				finalPosition.y += Float(tile.finish.y) * 5.0 * 0.01
//				finalPosition.z += Float(tile.finish.z) * 5.0 * 0.01
//
//				// Translate tile
//				currentTileEntity.position = finalPosition
//
//
//				// Update tilePositions
////				DispatchQueue.main.async {
////					for index in 0 ..< self.game.tilePositions.count {
////						if self.game.tilePositions[index].tileId == tileId! {
////							self.game.tilePositions[index].coordinates = tile.finish
////							break
////						}
////					}
////	//				self.game.tilesForTranslation.remove(at: index)
////				}
//			}
//		}
//		// Update tilePositions
////		DispatchQueue.main.async {
////			for tile in game.tilesForTranslation {
////				for index in 0 ..< game.tilePositions.count {
////					if game.tilePositions[index].coordinates == tile.start {
////						DispatchQueue.main.async {
////							game.tilePositions[index].coordinates = tile.finish
////						}
////					}
////				}
////			}
////		} THEORY: NO OBJECT CAN BE ACCESSED AND CHANGED IN THE SAME CODE SENT TO THE ASYNCHRONOUS THREAD
//		var newTilePositionsForTranslation = [TilePosition]()
//		DispatchQueue.main.async {
////			var newTilePositions = [TilePosition]()
//			for tilePosition in game.tilePositions {
//				for tileForTranslation in game.tilesForTranslation {
//					if tilePosition.coordinates == tileForTranslation.start {
//						newTilePositionsForTranslation.append(TilePosition(tileId: tilePosition.tileId, coordinates: tileForTranslation.finish))
//					} else {
//						newTilePositionsForTranslation.append(TilePosition(tileId: tilePosition.tileId, coordinates: tilePosition.coordinates))
//					}
//				}
//			}
//		}
//		DispatchQueue.main.async {
//			print("newTilePositionsForTranslation: \(newTilePositionsForTranslation)")
//			game.tilePositions = newTilePositionsForTranslation
//		}
//
//
//		DispatchQueue.main.async {
//			self.game.tilesForTranslation = []
////			self.removing = true
//		}
//		DispatchQueue.main.async {
//			// REMOVE TILES
//			for coordinates in self.game.tilesForRemoval {
//				// Find tileId
//	//				var tileId: String?
//				var tileIds = [String]()
//				for tilePosition in self.game.tilePositions {
//					if tilePosition.coordinates == coordinates {
//	//						tileId = tilePosition.tileId
//						tileIds.append(tilePosition.tileId)
//	//						break
//					}
//				}
//
//				if tileIds.count > 1 {
//					print("MORE THAN TWO")
//				}
////				print(self.game.tilesForRemoval)
////				print(self.game.tilePositions)
//				for tileId in tileIds {
//					// Remove tile entity from anchor
//					let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
//					let tileEntityForRemoval = gameAnchorEntity.findEntity(named: tileId)!
//	//				gameAnchorEntity.removeChild(tileEntityForRemoval)
//					gameAnchorEntity.removeChild(tileEntityForRemoval)
//
//					// Set coordinates of tile in tilePositions to nil to indicated tile is removed
////					DispatchQueue.main.async {
////						gameAnchorEntity.removeChild(tileEntityForRemoval)
////						for index in 0 ..< self.game.tilePositions.count {
////							if self.game.tilePositions[index].tileId == tileId {
////								self.game.tilePositions[index].coordinates = nil
////								break
////							}
////						}
////					}
//				}
//	//				// Remove tile entity from anchor
//	//				let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
//	//				let tileEntityForRemoval = gameAnchorEntity.findEntity(named: tileId!)!
//	////				gameAnchorEntity.removeChild(tileEntityForRemoval)
//	//
//	//				// Set coordinates of tile in tilePositions to nil to indicated tile is removed
//	//				DispatchQueue.main.async {
//	//					gameAnchorEntity.removeChild(tileEntityForRemoval)
//	//					for index in 0 ..< self.tilePositions.count {
//	//						if self.tilePositions[index].tileId == tileId! {
//	//							self.tilePositions[index].coordinates = nil
//	//							break
//	//						}
//	//					}
//	//				}
//
//			}
//		}
//
//		// Set coordinates of tile in tilePositions to nil to indicated tile is removed
////		DispatchQueue.main.async {
////			for coordinates in self.game.tilesForRemoval {
////				for index in 0 ..< game.tilePositions.count {
////					if game.tilePositions[index].coordinates == coordinates {
////						game.tilePositions[index].coordinates = nil
////					}
////				}
////			}
////		}
//		var newTilePositionsForRemoval = [TilePosition]()
//		DispatchQueue.main.async {
//			for tilePosition in game.tilePositions {
//				for tileForRemoval in game.tilesForRemoval {
//					if tilePosition.coordinates == tileForRemoval {
//						newTilePositionsForRemoval.append(TilePosition(tileId: tilePosition.tileId, coordinates: nil))
//					} else {
//						newTilePositionsForRemoval.append(TilePosition(tileId: tilePosition.tileId, coordinates: tilePosition.coordinates))
//					}
//				}
//			}
//		}
//		DispatchQueue.main.async {
//			print("newTilePositionsForRemoval: \(newTilePositionsForRemoval)")
//			game.tilePositions = newTilePositionsForRemoval
//		}
//
//		DispatchQueue.main.async {
//			self.game.tilesForRemoval = []
////				self.adding = true
//
//		}
//
//
//		DispatchQueue.main.async {
//			// PLACE NEW TILES
////				print(self.game.tilesForPlacement)
//			for index in 0 ..< self.game.tilesForPlacement.count {
//				let tile = self.game.tilesForPlacement[index]
//				let model = models[tile.tileName]!
//
//				if let modelEntity = model.modelEntity {
//					print("DUBUG: adding model to scene - \(model.modelName)")
//
//					// Clone the model entity to allow multiple simultaneous occurrences of the same tile value
//					let clonedModelEntity = modelEntity.clone(recursive: true)
//
//					// In order for entities to be placed relative to each other, they must all be child entities of the same
//					// anchor entity.
//					let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
//					let centrePosition = gameAnchorEntity.findEntity(named: "Frame")!.position
//
//					// Find tile position
//					var zeroPosition = centrePosition
//					zeroPosition.x -= 0.05
//					zeroPosition.y +=  0.005
//					zeroPosition.z -= 0.05
//
//					var finalPosition = zeroPosition
//					finalPosition.x += Float(tile.coordinates.x) * 5.0 * 0.01
//					finalPosition.y += Float(tile.coordinates.y) * 5.0 * 0.01
//					finalPosition.z += Float(tile.coordinates.z) * 5.0 * 0.01
//
//					// Add relevant data to tile entity
////						clonedModelEntity.name = self.nextTileId
//					clonedModelEntity.position = finalPosition
//
//					// Add tile to relevant data structures
////						gameAnchorEntity.addChild(clonedModelEntity)
//					clonedModelEntity.name = self.nextTileId
//					gameAnchorEntity.addChild(clonedModelEntity)
////						self.game.tilePositions.append((tileId: clonedModelEntity.name, coordinates: tile.coordinates))
//					self.game.tilePositions.append(TilePosition(tileId: clonedModelEntity.name, coordinates: tile.coordinates))
////					DispatchQueue.main.async { // nextTileId depends on this structure, so it can only be updated after use of nextTileId is complete
////						clonedModelEntity.name = self.nextTileId
////						gameAnchorEntity.addChild(clonedModelEntity)
//////						self.game.tilePositions.append((tileId: clonedModelEntity.name, coordinates: tile.coordinates))
////						self.game.tilePositions.append(TilePosition(tileId: clonedModelEntity.name, coordinates: tile.coordinates))
////					}
////						DispatchQueue.main.async {
//////							self.game.tilesForPlacement.remove(at: <#T##Int#>)
////						}
//
//				} else {
//					print("DEBUG: unable to load modelEntity for \(model.modelName)")
//				}
//			}
////				DispatchQueue.main.async {
////					self.game.tilesForPlacement = []
//////					self.translating = true
////				}
//		}
//
////		DispatchQueue.main.async {
////			for tile in game.tilesForPlacement {
////				game.tilePositions.append(TilePosition(tileId: nextTileId, coordinates: tile.coordinates))
////			}
////		}
//
//		DispatchQueue.main.async {
//			self.game.tilesForPlacement = []
////					self.translating = true
//		}
		
		// Remove all tiles, when a new game is started
//		DispatchQueue.main.async {
//			if self.resetGameAr {
//				let gameAnchorEntity = uiView.scene.findEntity(named: "Game")!
//				
//				for position in game.tilePositions where position.coordinates != nil {
//					gameAnchorEntity.removeChild(gameAnchorEntity.findEntity(named: position.tileId)!)
//				}
//			}
//		}
//		DispatchQueue.main.async {
//			resetGameAr = false
//		}
	}
}

#if DEBUG
struct ContentView_Preview : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
