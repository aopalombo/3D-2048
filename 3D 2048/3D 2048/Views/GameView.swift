//
//  GameView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 12/01/2021.
//

import SwiftUI

struct GameView: View {
	@Binding var inPlayMode: Bool
	@Binding var focusEntityNeeded: Bool
	@Binding var placeGrid: Bool
//	@Binding var tilesForTranslation: [(start: Coordinates, finish: Coordinates)]
//	@Binding var tilesForPlacement: [(tileName: String, coordinates: Coordinates)]
//	@Binding var tilesForRemoval: [Coordinates]
	@Binding var resetGameAr: Bool
	
	@Binding var highScore: Int
	@Binding var highestTile: Int
	@Binding var gamesWon: Int
	
	var models: [String: Model]
	
	@State private var gamePlaced = false
	
	var body: some View {
		if self.gamePlaced {
			PlayingGameView(inPlayMode: self.$inPlayMode, resetGameAr: self.$resetGameAr, highScore: $highScore, highestTile: $highestTile, gamesWon: $gamesWon)
		} else {
			GamePlacementView(inPlayMode: self.$inPlayMode, focusEntityNeeded: self.$focusEntityNeeded, placeGrid: self.$placeGrid, gamePlaced: self.$gamePlaced, models: self.models)
		}
	}
}

struct GamePlacementView: View {
	@EnvironmentObject var game: Game
	
	@Binding var inPlayMode: Bool
	@Binding var focusEntityNeeded: Bool
	@Binding var placeGrid: Bool
//	@Binding var tilesForPlacement: [(tileName: String, coordinates: Coordinates)]
	
	@Binding var gamePlaced: Bool
	
	var models: [String: Model]
	
	var body: some View {
		VStack {
			ZStack {
				RoundedRectangle(cornerRadius: 25)
					.fill(Color.white)
					.opacity(0.5)
				
				HStack {
					Button(action: {
						print("DEBUG: Menu selected from game placement view.")
						self.inPlayMode = false
						self.focusEntityNeeded = false
					}) {
						Image(systemName: "line.horizontal.3.circle.fill")
							.resizable()
							.frame(width: 40, height: 40)
							.foregroundColor(.black)
							.padding()
					}
					
					Text("Place The Game")
						.fontWeight(.bold)
						.font(.largeTitle)
						.frame(maxWidth: 300)
						.multilineTextAlignment(.center)
						.padding()
				}
			}
			.frame(maxWidth: 400, maxHeight: 60)
			.padding()
			
			Spacer()
			
			ZStack {
				RoundedRectangle(cornerRadius: 25)
					.fill(Color.white)
					.opacity(0.5)
				
				Button(action: {
					print("DEBUG: Checkmark selected.")
					self.startGame()
				}) {
					Image(systemName: "checkmark.circle.fill")
						.resizable()
						.frame(width: 40, height: 40)
						.foregroundColor(.black)
						.padding()
				}
			}
			.frame(maxWidth: 400, maxHeight: 60)
			.padding()
		}
	}
	
	func startGame() {
		// Setup AR
		self.focusEntityNeeded = false
		self.placeGrid = true
		
		// Switch to PlayingGameView
		self.gamePlaced = true
		
		DispatchQueue.main.async {
			// Load current game, if there is a playable game stored
//			let currentGame = UserDefaults.standard.object(forKey: "CurrentGame") as? Game ?? Game()
			var currentGame = self.game
			if let data = UserDefaults.standard.data(forKey: "CurrentGame") {
				let decoder = JSONDecoder()
				
				if let decoded = try? decoder.decode(Game.self, from: data) {
					currentGame = decoded
				}
			}
			
			if currentGame.gameStarted && !currentGame.gameOver {
				self.game.loadGame(game: currentGame)

			} else { // Or, start a new one
				self.game.newGame()
//				print(self.game.tilesForPlacement)
			}
//			self.game.newGame()
		}
//		// Load current game, if there is a playable game stored
//		let currentGame = UserDefaults.standard.object(forKey: "CurrentGame") as? Game ?? Game()
//		if currentGame.gameStarted && !currentGame.gameOver {
//			self.game.loadGame(game: currentGame)
//
//		} else { // Or, start a new one
//			self.game.newGame()
//			print(self.game.tilesForPlacement)
//		}
		
	}
}
	
struct PlayingGameView: View {
	@EnvironmentObject var game: Game
	
	@Binding var inPlayMode: Bool
//	@Binding var tilesForTranslation: [(start: Coordinates, finish: Coordinates)]
//	@Binding var tilesForPlacement: [(tileName: String, coordinates: Coordinates)]
//	@Binding var tilesForRemoval: [Coordinates]
	@Binding var resetGameAr: Bool
	
	@Binding var highScore: Int
	@Binding var highestTile: Int
	@Binding var gamesWon: Int
	
//	@State private var toggleToResetGame = false //{
//		didSet {
//			resetGame()
//		}
//	}
	
	var body: some View {
		VStack {
			GameStatsView(inPlayMode: self.$inPlayMode, resetGameAr: $resetGameAr)
			
			Spacer()
			
			GameControlsView(highScore: $highScore, highestTile: $highestTile, gamesWon: $gamesWon, resetGameAr: $resetGameAr, inPlayMode: $inPlayMode)
		}
	}
	
//	func resetGame() {
//		self.resetGameAr = true
//		self.game.newGame()
//	}
}

struct GameStatsView: View {
	@EnvironmentObject var game: Game
	
	@Binding var inPlayMode: Bool
	
//	@Binding var toggleToResetGame: Bool
	@Binding var resetGameAr: Bool
	
	@State private var showingNewGameView = false
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 25)
				.fill(Color.white)
				.opacity(0.5)
			
			HStack {
				Button(action: {
					print("DEBUG: Menu selected from playing game view.")
					self.inPlayMode = false
					
					game.pauseStopwatch()
				}) {
					Image(systemName: "line.horizontal.3.circle.fill")
						.resizable()
						.frame(width: 40, height: 40)
						.foregroundColor(.black)
						.padding()
				}
				
				Spacer()
				
				VStack {
					HStack {
						Text("Score:")
							.font(.title)
							.bold()
						Text(String(self.game.score))
							.font(.title)
							.bold()
					}
					
					HStack {
						Text("Moves:")
							.font(.headline)
							.bold()
						Text(String(self.game.moves))
							.font(.headline)
						Text("Time:")
							.font(.headline)
							.bold()
						if String(game.seconds).count == 1 {
							Text("\(String(game.minutes)):0\(String(game.seconds))")
								.font(.headline)
						} else {
							Text("\(String(game.minutes)):\(String(game.seconds))")
								.font(.headline)
						}
						
					}
				}
				.padding()
				
				Spacer()
				
				Button(action: {
					print("DEBUG: New game selected from game stats view.")
					self.showingNewGameView.toggle()
					
					game.pauseStopwatch()
					
				}) {
					Image(systemName: "arrow.clockwise.circle.fill")
						.resizable()
						.frame(width: 40, height: 40)
						.foregroundColor(.black)
						.padding()
				}
				.sheet(isPresented: $showingNewGameView, content: {
					NewGameView(resetGameAr: $resetGameAr).environmentObject(game)
						.allowAutoDismiss { false }
				})
//				.alert(isPresented: self.$showingResetAlert) {
//					Alert(title: Text("New Game"), message: Text("Resetting progress cannot be undone."), primaryButton: .destructive(Text("New Game")) {
//						print("DEBUG: New game selected from alert view.")
////						self.toggleToResetGame.toggle()
//					}, secondaryButton: .cancel() {
//						print("DEBUG: Cancel selected from alert view.")
//					})
//				}
			}
		}
		.frame(maxWidth: 400, maxHeight: 60)
		.padding()
	}
}

enum ActiveSheet: Identifiable {
	case gameWonView, gameOverView, gameWonAndOverView
	
	var id: Int {
		hashValue
	}
}

struct GameControlsView: View {
	@EnvironmentObject var game: Game
	
//	@Binding var tilesForTranslation: [(start: Coordinates, finish: Coordinates)]
//	@Binding var tilesForPlacement: [(tileName: String, coordinates: Coordinates)]
//	@Binding var tilesForRemoval: [Coordinates]
	
//	@Binding var toggleToResetGame: Bool
	
	@Binding var highScore: Int
	@Binding var highestTile: Int
	@Binding var gamesWon: Int
	
	@Binding var resetGameAr: Bool
	@Binding var inPlayMode: Bool
	
//	@State private var showingGameWonView = false
//	@State private var showingGameOverView = false
//	@State private var showingGameWonAndOverView = false
	@State var activeSheet: ActiveSheet?
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 25)
				.fill(Color.white)
				.opacity(0.5)
			
//			VStack {
//				HStack {
//					Button(action: {
//						print("DEBUG: Up selected")
//						playMove(direction: .above)
//					}) {
//						Image(systemName: "arrow.up.square.fill")
//							.resizable()
//							.frame(width: 45, height: 45)
//							.foregroundColor(.black)
//							.padding(5)
//					}
//
//					Button(action: {
//						print("DEBUG: Down selected")
//						playMove(direction: .below)
//					}) {
//						Image(systemName: "arrow.down.square.fill")
//							.resizable()
//							.frame(width: 45, height: 45)
//							.foregroundColor(.black)
//							.padding(5)
//					}
//
//					Button(action: {
//						print("DEBUG: Left selected")
//						playMove(direction: .left)
//					}) {
//						Image(systemName: "arrow.backward.square.fill")
//							.resizable()
//							.frame(width: 45, height: 45)
//							.foregroundColor(.black)
//							.padding(5)
//					}
//
//					Button(action: {
//						print("DEBUG: Right selected")
//						playMove(direction: .right)
//					}) {
//						Image(systemName: "arrow.right.square.fill")
//							.resizable()
//							.frame(width: 45, height: 45)
//							.foregroundColor(.black)
//							.padding(5)
//					}
//				}
//
//				HStack {
//					Button(action: {
//						print("DEBUG: Forward selected")
//						playMove(direction: .inFront)
//					}) {
//						Image(systemName: "arrow.down.left.square.fill")
//							.resizable()
//							.frame(width: 45, height: 45)
//							.foregroundColor(.black)
//							.padding(5)
//					}
//
//					Button(action: {
//						print("DEBUG: Back selected")
//						playMove(direction: .behind)
//					}) {
//						Image(systemName: "arrow.up.forward.square.fill")
//							.resizable()
//							.frame(width: 45, height: 45)
//							.foregroundColor(.black)
//							.padding(5)
//					}
//				}
//			}
			VStack {
				Text("Relative to 'Front'")
					.padding(.top, 5)
				HStack {
					// Keyboard arrows
					VStack {
						Button(action: {
							print("DEBUG: Up selected")
							playMove(direction: .above)
						}) {
							Image(systemName: "arrow.up.square.fill")
								.resizable()
								.frame(width: 45, height: 45)
								.foregroundColor(.black)
								.padding(5)
						}
						
						HStack {
							Button(action: {
								print("DEBUG: Left selected")
								playMove(direction: .left)
							}) {
								Image(systemName: "arrow.backward.square.fill")
									.resizable()
									.frame(width: 45, height: 45)
									.foregroundColor(.black)
									.padding(5)
							}
							
							Button(action: {
								print("DEBUG: Down selected")
								playMove(direction: .below)
							}) {
								Image(systemName: "arrow.down.square.fill")
									.resizable()
									.frame(width: 45, height: 45)
									.foregroundColor(.black)
									.padding(5)
							}
							
							Button(action: {
								print("DEBUG: Right selected")
								playMove(direction: .right)
							}) {
								Image(systemName: "arrow.right.square.fill")
									.resizable()
									.frame(width: 45, height: 45)
									.foregroundColor(.black)
									.padding(5)
							}
							
						}
						Text("Up/Down")
							.padding(.bottom, 5)
					}
					
					// '3D' forward/back arrows
					VStack {
						HStack {
							Button(action: {
								print("DEBUG: Forward selected")
								playMove(direction: .inFront)
							}) {
								Image(systemName: "arrow.down.left.square.fill")
									.resizable()
									.frame(width: 45, height: 45)
									.foregroundColor(.black)
									.padding(5)
							}
							
							Button(action: {
								print("DEBUG: Back selected")
								playMove(direction: .behind)
							}) {
								Image(systemName: "arrow.up.forward.square.fill")
									.resizable()
									.frame(width: 45, height: 45)
									.foregroundColor(.black)
									.padding(5)
							}
						}
						Text("Forward/Back")
					}
				}
			}
			.sheet(item: $activeSheet) { item in
				switch item {
				case .gameWonView:
					GameWonView(resetGameAr: $resetGameAr).environmentObject(game)
						.allowAutoDismiss { false }
				case .gameOverView:
					GameOverView(inPlayMode: $inPlayMode, resetGameAr: $resetGameAr).environmentObject(game)
						.allowAutoDismiss { false }
				case .gameWonAndOverView:
					GameWonAndOverView(inPlayMode: $inPlayMode, resetGameAr: $resetGameAr).environmentObject(game)
						.allowAutoDismiss { false }
				}
			}
//			.sheet(isPresented: $showingGameWonView, content: {
//				GameWonView(resetGameAr: $resetGameAr).environmentObject(game)
//					.allowAutoDismiss { false }
//			})
//			.sheet(isPresented: $showingGameOverView, content: {
//				GameOverView(inPlayMode: $inPlayMode, resetGameAr: $resetGameAr).environmentObject(game)
//					.allowAutoDismiss { false }
//			})
//			.sheet(isPresented: $showingGameWonAndOverView, content: {
//				GameWonAndOverView(inPlayMode: $inPlayMode, resetGameAr: $resetGameAr).environmentObject(game)
//					.allowAutoDismiss { false }
//			})
		}
		.frame(maxWidth: 400, maxHeight: 150)
		.padding()
	}
	
	func playMove(direction: Direction) {
//		print(self.game.tilesForPlacement)
		
//		let results = self.game.playMove(userDirection: direction)
//
//		// NOTE: order may be important!
//		// Add tiles for translation
//		self.game.tilesForTranslation = results.translations
//
//		// Add tiles for removal
//		for merge in results.merges {
//			self.game.tilesForRemoval.append(merge.coordinates)
//		}
//
//		// Add new tiles
//		for merge in results.merges {
//			self.game.tilesForPlacement.append((tileName: ("Tile" + String(merge.value)), coordinates: merge.coordinates))
//		}
//		for tile in results.newTiles {
//			self.game.tilesForPlacement.append((tileName: ("Tile" + String(tile.value)), coordinates: tile.coordinates))
//		}
		
//		DispatchQueue.main.async {
//			self.game.playMove(userDirection: direction)
//		}
		self.game.playMove(userDirection: direction)
		
		if !game.cheatMode {
			if game.score > highScore {
				highScore = game.score
			}
			
			// Highest tile
			for x in 0 ... 2 {
				for y in 0 ... 2 {
					for z in 0 ... 2 {
						if game.matrix[x][y][z] > highestTile {
							highestTile = game.matrix[x][y][z]
						}
					}
				}
			}
		}
		
		
		// Games won
		if game.gameWon && !game.gameWonRecorded {
			if !game.cheatMode {
				gamesWon += 1
			}
			
			game.gameWonRecorded = true
			
			game.pauseStopwatch()
			
			if game.gameOver {
//				showingGameWonAndOverView.toggle()
				activeSheet = .gameWonAndOverView
			} else {
//				showingGameWonView.toggle()
				activeSheet = .gameWonView
			}
		}
		
		
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(self.game) {
			UserDefaults.standard.set(data, forKey: "CurrentGame")
		}
		
		self.game.printMatrix()
		
		if !game.gameWon && game.gameOver {
			game.pauseStopwatch()
			
//			showingGameOverView = true
			activeSheet = .gameOverView
		}
	}
}

//struct GameView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameView()
//    }
//}
