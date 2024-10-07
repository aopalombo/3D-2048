//
//  EnableCheatModeView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 23/01/2021.
//

import SwiftUI

struct EnableCheatModeView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var game: Game
	
    var body: some View {
		if !game.cheatMode {
			// Enable cheat mode view
			VStack {
				Text("Enable Cheat Mode?")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding()
				Text("In this mode, two '2' tiles merge to make '512'. This is intended for testing purposes only.")
					.font(.body)
					.multilineTextAlignment(.center)
					.padding()
				Text("Statistics will not be recorded. A new game will be started.")
					.font(.body)
					.fontWeight(.bold)
					.multilineTextAlignment(.center)
					.padding()
				Spacer()
				
				Button(action: {
					print("DEBUG: Enable selected from enable cheat mode view.")
					
					DispatchQueue.main.async {
						var currentGame = self.game
						if let data = UserDefaults.standard.data(forKey: "CurrentGame") {
							let decoder = JSONDecoder()
							
							if let decoded = try? decoder.decode(Game.self, from: data) {
								currentGame = decoded
							}
						}
						currentGame.newGame()
						currentGame.cheatMode = true
						
						self.game.loadGame(game: currentGame)
						
						let encoder = JSONEncoder()
						if let data = try? encoder.encode(self.game) {
							UserDefaults.standard.set(data, forKey: "CurrentGame")
						}
						
					}
					
//					game.cheatMode = true
					
					self.presentationMode.wrappedValue.dismiss()
				}) {
					Text("Enable")
						.frame(width: 300.0, height: 50.0)
						.font(.headline)
						.foregroundColor(.black)
						.cornerRadius(15)
						.padding()
				}
				
				Button(action: {
					print("DEBUG: Cancel selected from enable cheat mode view.")
					
					self.presentationMode.wrappedValue.dismiss()
				}) {
					Text("Cancel")
						.frame(width: 300.0, height: 50.0)
						.background(Color.black)
						.foregroundColor(.white)
						.font(.headline)
						.cornerRadius(15)
						.padding()
						.padding(.bottom, 30)
				}
			}
		} else {
			// Disable cheat mode view
			VStack {
				Text("Disable Cheat Mode?")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding()
				Text("In this mode, tiles combine as normal.")
					.font(.body)
					.multilineTextAlignment(.center)
					.padding()
				Text("Statistics will be recorded. A new game will be started.")
					.font(.body)
					.fontWeight(.bold)
					.multilineTextAlignment(.center)
					.padding()
				Spacer()
				
				Button(action: {
					print("DEBUG: Cancel selected from disable cheat mode view.")
					
					self.presentationMode.wrappedValue.dismiss()
				}) {
					Text("Cancel")
						.frame(width: 300.0, height: 50.0)
						.font(.headline)
						.foregroundColor(.black)
						.cornerRadius(15)
						.padding()
				}
				
				Button(action: {
					print("DEBUG: Disable selected from disable cheat mode view.")
					
					DispatchQueue.main.async {
						var currentGame = self.game
						if let data = UserDefaults.standard.data(forKey: "CurrentGame") {
							let decoder = JSONDecoder()
							
							if let decoded = try? decoder.decode(Game.self, from: data) {
								currentGame = decoded
							}
						}
						currentGame.newGame()
						currentGame.cheatMode = false
						
						self.game.loadGame(game: currentGame)
						
						let encoder = JSONEncoder()
						if let data = try? encoder.encode(self.game) {
							UserDefaults.standard.set(data, forKey: "CurrentGame")
						}
					}
					
//					game.cheatMode = false
					
					self.presentationMode.wrappedValue.dismiss()
				}) {
					Text("Disable")
						.frame(width: 300.0, height: 50.0)
						.background(Color.black)
						.foregroundColor(.white)
						.font(.headline)
						.cornerRadius(15)
						.padding()
						.padding(.bottom, 30)
				}
			}
		}
		
    }
}

//struct DisableCheatModeView: View {
//	@Environment(\.presentationMode) var presentationMode
//
//	@EnvironmentObject var game: Game
//
//	var body: some View {
//		VStack {
//			Text("Disable Cheat Mode?")
//				.font(.largeTitle)
//				.fontWeight(.bold)
//				.padding()
//			Text("In this mode, two '2' tiles merge to make '512'. This is intended for testing purposes only.")
//				.font(.body)
//				.multilineTextAlignment(.center)
//				.padding()
//			Text("Statistics will not be recorded.")
//				.font(.body)
//				.fontWeight(.bold)
//				.multilineTextAlignment(.center)
//				.padding()
//			Spacer()
//
//			Button(action: {
//				print("DEBUG: Cancel selected from disable cheat mode view.")
//
//				self.presentationMode.wrappedValue.dismiss()
//			}) {
//				Text("Cancel")
//					.frame(width: 300.0, height: 50.0)
//					.font(.headline)
//					.foregroundColor(.black)
//					.cornerRadius(15)
//					.padding()
//			}
//
//			Button(action: {
//				print("DEBUG: Disable selected from disable cheat mode view.")
//
//				game.cheatMode = false
//
//				self.presentationMode.wrappedValue.dismiss()
//			}) {
//				Text("Disable")
//					.frame(width: 300.0, height: 50.0)
//					.background(Color.black)
//					.foregroundColor(.white)
//					.font(.headline)
//					.cornerRadius(15)
//					.padding()
//					.padding(.bottom, 30)
//			}
//		}
//	}
//}

struct EnableCheatModeView_Previews: PreviewProvider {
    static var previews: some View {
        EnableCheatModeView()
    }
}
