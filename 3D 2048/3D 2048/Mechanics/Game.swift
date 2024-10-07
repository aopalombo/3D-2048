//
//  Game.swift
//  3D 2048
//
//  Created by Andrew Palombo on 08/01/2021.
//

import Foundation

class Game: ObservableObject, Codable {
	static var shared = Game() // Ensures only one instance of game can exist at any one time.
	private let matrixSize = 3
	@Published var matrix = [[[Int]]]()
	@Published var score: Int = 0
	@Published var moves: Int = 0
	@Published var gameWon = false
	@Published var gameWonRecorded = false
	@Published var gameStarted = false
	//add stopwatch?
	@Published var tilePositions = [TilePosition]()
	@Published var tilesForTranslation = [(tileId: String, finish: Coordinates)]()
	@Published var tilesForRemoval = [String]()
	@Published var tilesForFirstPlacement = [(tileName: String, tileId: String, coordinates: Coordinates)]()
	@Published var tilesForSecondPlacement = [(tileName: String, tileId: String, coordinates: Coordinates)]()
	
	@Published var updateView = false
	
	@Published var totalSeconds = 0
	var minutes: Int {
		totalSeconds / 60
	}
	var seconds: Int {
		totalSeconds % 60
	}
	
	var timer: Timer?
	
	@Published var cheatMode = false
	
	var gameOver: Bool {
		//check for empty spaces
		if !(emptySpaceCoordinates.isEmpty) {
			return false
		}
		//check for adjacent tiles with the same value
		for x in 0...(matrixSize - 1) {
			for y in 0...(matrixSize - 1) {
				for z in 0...(matrixSize - 1) {
					let currentCoordinates = Coordinates(x: x, y: y, z: z)
					let value = getValueFromCoordinates(coordinates: currentCoordinates)!
					for direction in Direction.allCases where direction != .none {
						if getTile(inDirection: direction, from: currentCoordinates)?.value == value {
							return false
						}
					}
				}
			}
		}
		return true
	}
	
	private var emptySpaceCoordinates: [Coordinates] {
		var results = [Coordinates]()
		for x in 0...(matrixSize - 1) {
			for y in 0...(matrixSize - 1) {
				for z in 0...(matrixSize - 1) {
					let value = matrix[x][y][z]
					if value == 0 {
						results.append(Coordinates(x: x, y: y, z: z))
					}
				}
			}
		}
		return results
	}
	
	private var nextTileId: String {
		String(tilePositions.count)
	}
	
	init() {
		
	}
	
	enum CodingKeys: CodingKey {
		case matrix
		case score
		case moves
		case gameWon
		case gameWonRecorded
		case gameStarted
		
		case tilePositions
		
		case totalSeconds
		
		case cheatMode
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		matrix = try container.decode([[[Int]]].self, forKey: .matrix)
		score = try container.decode(Int.self, forKey: .score)
		moves = try container.decode(Int.self, forKey: .moves)
		gameWon = try container.decode(Bool.self, forKey: .gameWon)
		gameWonRecorded = try container.decode(Bool.self, forKey: .gameWonRecorded)
		gameStarted = try container.decode(Bool.self, forKey: .gameStarted)
		
		tilePositions = try container.decode([TilePosition].self, forKey: .tilePositions)
		tilesForTranslation = [(tileId: String, finish: Coordinates)]()
		tilesForRemoval = [String]()
		tilesForFirstPlacement = [(tileName: String, tileId: String, coordinates: Coordinates)]()
		tilesForSecondPlacement = [(tileName: String, tileId: String, coordinates: Coordinates)]()
		
		totalSeconds = try container.decode(Int.self, forKey: .totalSeconds)
		
		cheatMode = try container.decode(Bool.self, forKey: .cheatMode)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(matrix, forKey: .matrix)
		try container.encode(score, forKey: .score)
		try container.encode(moves, forKey: .moves)
		try container.encode(gameWon, forKey: .gameWon)
		try container.encode(gameWonRecorded, forKey: .gameWonRecorded)
		try container.encode(gameStarted, forKey: .gameStarted)
		
		try container.encode(tilePositions, forKey: .tilePositions)
		
		try container.encode(totalSeconds, forKey: .totalSeconds)
		
		try container.encode(cheatMode, forKey: .cheatMode)
	}
	
	func newGame() {
		score = 0
		moves = 0
		gameStarted = true
		gameWon = false
		
//		tilePositions = []
		tilesForTranslation = []
		tilesForRemoval = []
		tilesForFirstPlacement = []
		tilesForSecondPlacement = []
		
		//Generates something like: [[[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[2, 0, 0], [0, 0, 0], [2, 0, 0]]]
		//generate empty 3x3 3d matrix
		var newMatrix = [[[Int]]]()
		for i in 0...(matrixSize - 1) {
			newMatrix.append([[Int]]())
			for j in 0...(matrixSize - 1) {
				newMatrix[i].append([Int]())
				for _ in 0...(matrixSize - 1) {
					newMatrix[i][j].append(0)
				}
			}
		}
		var startingTiles = [(coordinates: Coordinates, value: Int)]()
		//add two starting values at two random locations, each either 2 or 4
		for _ in 0...1 {
			//find an unused position, avoids 1/27 chance of identical locations picked resulting in one starting value
			var newPositionFound = false
			while !newPositionFound {
				let x = Int.random(in: 0 ... (matrixSize - 1))
				let y = Int.random(in: 0 ... (matrixSize - 1))
				let z = Int.random(in: 0 ... (matrixSize - 1))
				if newMatrix[x][y][z] == 0 {
					newPositionFound = true
					let randomProbability = Double.random(in: 0.0 ..< 1.0)
					if randomProbability < 0.75 {
						newMatrix[x][y][z] = 2
						startingTiles.append((coordinates: Coordinates(x: x, y: y, z: z), value: 2))
					} else {
						newMatrix[x][y][z] = 4
						startingTiles.append((coordinates: Coordinates(x: x, y: y, z: z), value: 4))
					}
				}
			}
		}
		
		// Save the new matrix
		matrix = newMatrix
		
		// Remove old tiles
		for tilePosition in tilePositions where tilePosition.coordinates != nil {
			tilesForRemoval.append(tilePosition.tileId)
		}
		tilePositions = []
		
		// Add new tiles
		for tile in startingTiles {
			let newTileId = nextTileId
			// Record new tiles in tilePositions
			tilePositions.append(TilePosition(tileId: newTileId, coordinates: tile.coordinates))
			
			// Place the tiles in the AR view
			tilesForFirstPlacement.append((tileName: ("Tile" + String(tile.value)), tileId: newTileId, coordinates: tile.coordinates))
		}
		
		if let currentTimer = timer {
			if currentTimer.isValid {
				pauseStopwatch()
			}
		}
		totalSeconds = 0
		
		updateView = true
	}
	
	func loadGame(game: Game) {
		// Copy over game properties
		matrix = game.matrix
		score = game.score
		moves = game.moves
		gameWon = game.gameWon
		gameStarted = true
		totalSeconds = game.totalSeconds
		
		cheatMode = game.cheatMode
		
		tilePositions = [] // Added in update view method from tilesForPlacement
		tilesForTranslation = []
		tilesForRemoval = []
		tilesForFirstPlacement = []
		tilesForSecondPlacement = []
		
		// Update tilePositions and AR view
		for x in 0 ..< matrixSize {
			for y in 0 ..< matrixSize {
				for z in 0 ..< matrixSize {
					let coordinates = Coordinates(x: x, y: y, z: z)
					let value = getValueFromCoordinates(coordinates: coordinates)!
					if value != 0 {
						let newTileId = nextTileId
						// Record tiles in tilePositions
						tilePositions.append(TilePosition(tileId: newTileId, coordinates: coordinates))
						
						// Place tiles in AR
						tilesForFirstPlacement.append((tileName: ("Tile" + String(value)), tileId: newTileId, coordinates: coordinates))
					}
				}
			}
		}
		
		updateView = true
	}
	
	func playMove(userDirection direction: Direction) {
		let moveResults = findTileTranslationsAndMerges(userDirection: direction)
		var newTiles = [(coordinates: Coordinates, value: Int)]()
		if !(moveResults.translations.isEmpty) {
			moves += 1
			updateScore(merges: moveResults.merges)
			updateGameWon(merges: moveResults.merges)
			newTiles = addNewTiles()
		}
		
//		// NOTE: order may be important!
//		// Add tiles for translation
//		tilesForTranslation = moveResults.translations
////		print(tilesForTranslation)
//		// Add tiles for removal
//		for merge in moveResults.merges {
//			tilesForRemoval.append(merge.coordinates)
//		}
//
//		// Add new tiles
//		for merge in moveResults.merges {
//			tilesForPlacement.append((tileName: ("Tile" + String(merge.value)), coordinates: merge.coordinates))
//		}
//		for tile in newTiles {
//			tilesForPlacement.append((tileName: ("Tile" + String(tile.value)), coordinates: tile.coordinates))
//		}
		
		// Translation
		for translation in moveResults.translations {
			for index in 0 ..< tilePositions.count {
				let tilePosition = tilePositions[index]
				if tilePosition.coordinates == translation.start {
					// Update tilePositions
					tilePositions[index].coordinates = translation.finish
					
					// Update tilesForTranslation
					tilesForTranslation.append((tileId: tilePosition.tileId, finish: translation.finish))
					break
				}
			}
		}
		print("tilesForTranslation: \(tilesForTranslation)")
		
		// Removal
		for removal in moveResults.merges {
			for index in 0 ..< tilePositions.count {
				let tilePosition = tilePositions[index]
				if tilePosition.coordinates == removal.coordinates {
					// Update tilePositions
					tilePositions[index].coordinates = nil
					
					// Update tilesForRemoval
					tilesForRemoval.append(tilePosition.tileId)
				}
			}
		}
		
		// First placement
		for placement in moveResults.merges {
			// Update tilePositions
			let newTileId = nextTileId
			tilePositions.append(TilePosition(tileId: newTileId, coordinates: placement.coordinates))
			
			// Update tilesForFirstPlacement
			tilesForFirstPlacement.append((tileName: ("Tile" + String(placement.value)), tileId: newTileId, coordinates: placement.coordinates))
		}
		
		// Second placement
		for placement in newTiles {
			// Update tilePositions
			let newTileId = nextTileId
			tilePositions.append(TilePosition(tileId: newTileId, coordinates: placement.coordinates))
			
			// Update tilesForSecondPlacement
			tilesForSecondPlacement.append((tileName: ("Tile" + String(placement.value)), tileId: newTileId, coordinates: placement.coordinates))
		}
		
		if let currentTimer = timer {
			if !currentTimer.isValid {
				startStopwatch()
			}
		} else {
			startStopwatch()
		}
		
		updateView = true
	}
	
	func startStopwatch() {
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementStopwatch), userInfo: nil, repeats: true)
	}
	
	func pauseStopwatch() {
		timer?.invalidate()
	}
	
	@objc func incrementStopwatch() {
		totalSeconds += 1
	}
	
	func printMatrix() {
		let x = 0
		var y = 2
		let z = 2
		print("+—————+ +—————+ +—————+")
		print("|\(matrix[x][y][z])+\(matrix[x+1][y][z])+\(matrix[x+2][y][z])| |\(matrix[x][y][z-1])+\(matrix[x+1][y][z-1])+\(matrix[x+2][y][z-1])| |\(matrix[x][y][z-2])+\(matrix[x+1][y][z-2])+\(matrix[x+2][y][z-2])|")
		y -= 1
		print("|\(matrix[x][y][z])+\(matrix[x+1][y][z])+\(matrix[x+2][y][z])| |\(matrix[x][y][z-1])+\(matrix[x+1][y][z-1])+\(matrix[x+2][y][z-1])| |\(matrix[x][y][z-2])+\(matrix[x+1][y][z-2])+\(matrix[x+2][y][z-2])|")
		y -= 1
		print("|\(matrix[x][y][z])+\(matrix[x+1][y][z])+\(matrix[x+2][y][z])| |\(matrix[x][y][z-1])+\(matrix[x+1][y][z-1])+\(matrix[x+2][y][z-1])| |\(matrix[x][y][z-2])+\(matrix[x+1][y][z-2])+\(matrix[x+2][y][z-2])|")
		print("+—————+ +—————+ +—————+")
	}
	
	private func addNewTiles() -> [(coordinates: Coordinates, value: Int)] {
		// Adds one or two new tiles to the matrix and returns the details of these tiles
		var newTiles = [(coordinates: Coordinates, value: Int)]()
		var noTiles = 0
		if emptySpaceCoordinates.count > 1 {
			noTiles = Int.random(in: 0 ... 1)
		}
		for _ in 0 ... noTiles {
			let newTileCoordinates = emptySpaceCoordinates.randomElement()!
			var newValue = 0
			let valueProbability = Double.random(in: 0.0 ..< 1.0)
			if valueProbability < 0.75 {
				newValue = 2
			} else {
				newValue = 4
			}
			matrix[newTileCoordinates.x][newTileCoordinates.y][newTileCoordinates.z] = newValue
			newTiles.append((coordinates: newTileCoordinates, value: newValue))
		}
		return newTiles
	}
	
	private func getTile(inDirection direction: Direction, from startingCoordinates: Coordinates) -> (coordinates: Coordinates, value: Int)? {
		//translate coordinates, in direction given, one tile along, if there is a tile in this direction
		var translatedCoordinates = startingCoordinates
		switch direction {
		case .none:
			break
		case .left:
			translatedCoordinates.x = startingCoordinates.x - 1
		case .right:
			translatedCoordinates.x = startingCoordinates.x + 1
		case .inFront:
//			translatedCoordinates.y = startingCoordinates.y - 1
			translatedCoordinates.z = startingCoordinates.z + 1
		case .behind:
//			translatedCoordinates.y = startingCoordinates.y + 1
			translatedCoordinates.z = startingCoordinates.z - 1
		case .above:
//			translatedCoordinates.z = startingCoordinates.z + 1
			translatedCoordinates.y = startingCoordinates.y + 1
		case .below:
//			translatedCoordinates.z = startingCoordinates.z - 1
			translatedCoordinates.y = startingCoordinates.y - 1
		}
		if let value = getValueFromCoordinates(coordinates: translatedCoordinates) {
			return (coordinates: translatedCoordinates, value: value)
		}
		return nil
	}
	
	func getValueFromCoordinates(coordinates: Coordinates) -> Int? {
		//guards against value outside of matrix
		let coordinatesInRange = 0 ... (matrixSize - 1)
		if !(coordinatesInRange.contains(coordinates.x)) || !(coordinatesInRange.contains(coordinates.y)) || !(coordinatesInRange.contains(coordinates.z)) {
			return nil
		}
		return matrix[coordinates.x][coordinates.y][coordinates.z]
	}
	
	private func findTileTranslationsAndMerges(userDirection direction: Direction) -> (translations: [(start: Coordinates, finish: Coordinates)], merges: [(coordinates: Coordinates, value: Int)]) {
		//NOTE: also applies changes to matrix
		//the coordinates for all tiles on the opposite side of the matrix to the direction are all the combinations of coordinate stored in xs, ys and zs
		var xs = Array(0...(matrixSize - 1))
		var ys = Array(0...(matrixSize - 1))
		var zs = Array(0...(matrixSize - 1))
		switch direction {
		case .left:
			xs = [(matrixSize - 1)]
		case .right:
			xs = [0]
		case .inFront:
//			ys = [(matrixSize - 1)]
			zs = [0]
		case .behind:
//			ys = [0]
			zs = [(matrixSize - 1)]
		case .above:
//			zs = [0]
			ys = [0]
		case .below:
//			zs = [(matrixSize - 1)]
			ys = [(matrixSize - 1)]
		default:
			break
		}
		
		var translations = [(start: Coordinates, finish: Coordinates)]()
		var merges = [(coordinates: Coordinates, value: Int)]()
		//for each tile on the starting side of the matrix
		for x in xs {
			for y in ys {
				for z in zs {
					var currentTiles = [(start: Coordinates, finish: Coordinates, value: Int, merged: Bool)]()
					var removedTiles = [(start: Coordinates, finish: Coordinates, value: Int, merged: Bool)]()
					//add tiles to currentTiles
					var currentCoordinates = Coordinates(x: x, y: y, z: z)
					for pos in 0...(matrixSize - 1) {
						currentTiles.append((start: currentCoordinates, finish: currentCoordinates, value: getValueFromCoordinates(coordinates: currentCoordinates)!, merged: false))
						if pos < matrixSize - 1 {
							currentCoordinates = getTile(inDirection: direction, from: currentCoordinates)!.coordinates
						}
					}
					//check for moves in array according to game rules
					let assessmentOrder = Array(0...(matrixSize - 2)).reversed()
					for var i in assessmentOrder where currentTiles[i].value != 0 {
						var moreComparisonsNeeded = true
						while moreComparisonsNeeded && i < currentTiles.count - 1 {
							//compare to tile at higher position in array
							//check for zero
							if currentTiles[i + 1].value == 0 {
								matrix[currentTiles[i].finish.x][currentTiles[i].finish.y][currentTiles[i].finish.z] = 0
								matrix[currentTiles[i + 1].finish.x][currentTiles[i + 1].finish.y][currentTiles[i + 1].finish.z] = currentTiles[i].value
								let oldZeroCoordinates = currentTiles[i + 1].finish
								currentTiles[i + 1].finish = currentTiles[i].finish
								currentTiles[i].finish = oldZeroCoordinates
								currentTiles.swapAt(i, i + 1)
								i += 1
								//check for the same value
							} else if currentTiles[i + 1].value == currentTiles[i].value && !(currentTiles[i + 1].merged) {
								matrix[currentTiles[i].finish.x][currentTiles[i].finish.y][currentTiles[i].finish.z] = 0
								if cheatMode && matrix[currentTiles[i + 1].finish.x][currentTiles[i + 1].finish.y][currentTiles[i + 1].finish.z] == 2 {
									matrix[currentTiles[i + 1].finish.x][currentTiles[i + 1].finish.y][currentTiles[i + 1].finish.z] = 512
								} else {
									matrix[currentTiles[i + 1].finish.x][currentTiles[i + 1].finish.y][currentTiles[i + 1].finish.z] *= 2
								}
								
								let newZeroCoordinates = currentTiles[i].finish
								currentTiles[i].finish = currentTiles[i + 1].finish
								removedTiles.append(currentTiles[i])
								currentTiles[i].value = 0
								currentTiles[i].finish = newZeroCoordinates
								if cheatMode && currentTiles[i + 1].value == 2 {
									currentTiles[i + 1].value = 512
								} else {
									currentTiles[i + 1].value *= 2
								}
								
								currentTiles[i + 1].merged = true
								moreComparisonsNeeded = false
							} else {
								moreComparisonsNeeded = false
							}
						}
					}
					//extract translations and new tiles
					for tile in currentTiles + removedTiles where tile.value != 0 {
						if tile.start != tile.finish {
							translations.append((start: tile.start, finish: tile.finish))
						}
						if tile.merged {
							merges.append((coordinates: tile.finish, value: tile.value))
						}
					}
				}
			}
		}
		return (translations: translations, merges: merges)
	}
	
	private func updateScore(merges: [(coordinates: Coordinates, value: Int)]) {
		for merge in merges {
			score += merge.value
		}
	}
	
	private func updateGameWon(merges: [(coordinates: Coordinates, value: Int)]) {
		for merge in merges {
			if merge.value == 2048 {
				gameWon = true
			}
		}
	}
}

enum Direction: String, Codable, CaseIterable {
	case none
	case left
	case right
	case inFront
	case behind
	case above
	case below
}

struct Coordinates: Equatable, Codable {
	var x: Int
	var y: Int
	var z: Int
}

struct TilePosition: Codable {
	var tileId: String
	var coordinates: Coordinates?
}
//@Published var tilePositions = [(tileId: String, coordinates: Coordinates?)]()
