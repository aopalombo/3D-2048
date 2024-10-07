//
//  AboutView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 08/01/2021.
//

import SwiftUI

struct AboutView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var game: Game
	
	@State private var cheatModeCount = 0 {
		didSet {
			if cheatModeCount == 11 {
				cheatModeCount = 1
			}
		}
	}
	@State private var showingEnableCheatModeView = false
	
    var body: some View {
		VStack {
			HStack {
				Spacer()
				Button(action: {
						self.presentationMode.wrappedValue.dismiss()}) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
						.font(.system(size: 25, weight: .bold))
						.padding([.top, .trailing])
				}
			}
			Text("About 3D 2048")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundColor(.black)
				.minimumScaleFactor(0.8)
				.padding([.bottom, .leading, .trailing])
			Spacer()
			Form {
				Section {
					Link("App Support", destination: URL(string: "https://aopalombo.wixsite.com/3d2048/app-support")!)
						.accentColor(.black)
				}
				Section {
					Link("Privacy Policy", destination: URL(string: "https://aopalombo.wixsite.com/3d2048/privacy-policy")!)
						.accentColor(.black)
				}
				Section {
					Link("Original 2048 by Gabriele Cirulli", destination: URL(string: "https://play2048.co")!)
						.accentColor(.black)
				}
				Section {
					Button(action: {
						cheatModeCount += 1
						print("DEBUG: cheatModeCount is \(cheatModeCount)")
						
						if cheatModeCount == 10 {
							// Load last game so that after reopening the app, the correct enable/disable view is shown
							var currentGame = self.game
							if let data = UserDefaults.standard.data(forKey: "CurrentGame") {
								let decoder = JSONDecoder()
								
								if let decoded = try? decoder.decode(Game.self, from: data) {
									currentGame = decoded
								}
							}
							
							if currentGame.gameStarted {
								self.game.loadGame(game: currentGame)
							} else {
								self.game.newGame()
							}
							
							
							showingEnableCheatModeView.toggle()
						}
					}) {
						Text("Version 0.1")
							.foregroundColor(.black)
					}.sheet(isPresented: $showingEnableCheatModeView) {
						EnableCheatModeView().environmentObject(game)
					}
				}
				Section {
					Text("© Andrew Palombo")
				}
				
			}
		}
		.background(Color(UIColor.systemBackground))
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
