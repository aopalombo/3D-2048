//
//  GameModel.swift
//  3D 2048 Command Line
//
//  Created by Andrew Palombo on 06/01/2021.
//

import Foundation

class GameModel {
	private let matrixSize = 3
	var	matrix = [[[Int]]]()
	var score: Int = 0
	var moves: Int = 0
	var gameWon = false
	//add stopwatch?
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
	
	func newGame() -> [(coordinates: Coordinates, value: Int)] {
		score = 0
		moves = 0
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
					if randomProbability < 0.5 {
						newMatrix[x][y][z] = 2
						startingTiles.append((coordinates: Coordinates(x: x, y: y, z: z), value: 2))
					} else {
						newMatrix[x][y][z] = 4
						startingTiles.append((coordinates: Coordinates(x: x, y: y, z: z), value: 4))
					}
				}
			}
		}
		matrix = newMatrix
		return startingTiles
	}
	
	func playMove(userDirection direction: Direction) -> (translations: [(start: Coordinates, finish: Coordinates)], merges: [(coordinates: Coordinates, value: Int)], newTiles: [(coordinates: Coordinates, value: Int)]) {
		let moveResults = findTileTranslationsAndMerges(userDirection: direction)
		var newTiles = [(coordinates: Coordinates, value: Int)]()
		if !(moveResults.translations.isEmpty) {
			moves += 1
			updateScore(merges: moveResults.merges)
			updateGameWon(merges: moveResults.merges)
			newTiles = addNewTiles()
		}
		return (translations: moveResults.translations, merges: moveResults.merges, newTiles: newTiles)
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
		//adds one or two new tiles to the matrix and returns the details of these tiles
		var newTiles = [(coordinates: Coordinates, value: Int)]()
		var noTiles = 0
		if emptySpaceCoordinates.count > 1 {
			noTiles = Int.random(in: 0 ... 1)
		}
		for _ in 0 ... noTiles {
			let newTileCoordinates = emptySpaceCoordinates.randomElement()!
			var newValue = 0
			let valueProbability = Double.random(in: 0.0 ..< 1.0)
			if valueProbability < 0.5 {
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
			translatedCoordinates.y = startingCoordinates.y - 1
		case .behind:
			translatedCoordinates.y = startingCoordinates.y + 1
		case .above:
			translatedCoordinates.z = startingCoordinates.z + 1
		case .below:
			translatedCoordinates.z = startingCoordinates.z - 1
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
			ys = [(matrixSize - 1)]
		case .behind:
			ys = [0]
		case .above:
			zs = [0]
		case .below:
			zs = [(matrixSize - 1)]
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
								matrix[currentTiles[i + 1].finish.x][currentTiles[i + 1].finish.y][currentTiles[i + 1].finish.z] *= 2
								let newZeroCoordinates = currentTiles[i].finish
								currentTiles[i].finish = currentTiles[i + 1].finish
								removedTiles.append(currentTiles[i])
								currentTiles[i].value = 0
								currentTiles[i].finish = newZeroCoordinates
								currentTiles[i + 1].value *= 2
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

struct Coordinates: Equatable {
	var x: Int
	var y: Int
	var z: Int
}
