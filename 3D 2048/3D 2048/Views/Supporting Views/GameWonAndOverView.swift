//
//  GameWonAndOverView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 16/01/2021.
//

import SwiftUI

struct GameWonAndOverView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var game: Game
	
	@Binding var inPlayMode: Bool
	
	@Binding var resetGameAr: Bool
	
	var body: some View {
		VStack {
			Text("Game Won!")
				.font(.largeTitle)
				.fontWeight(.bold)
				.padding()
			Text("However, you have no more moves left.")
				.font(.body)
				.padding()
			Text("You scored \(String(game.score)) in \(String(game.minutes)) minute(s) \(String(game.seconds)) second(s) with \(String(game.moves)) moves.")
				.font(.body)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
				.padding()
			Spacer()
			
			Button(action: {
				print("DEBUG: Menu selected from game won and over view.")
				
				inPlayMode = false
				
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Menu")
					.frame(width: 300.0, height: 50.0)
					.font(.headline)
					.foregroundColor(.black)
					.cornerRadius(15)
					.padding()
			}
			
			Button(action: {
				print("DEBUG: New game selected from game won and over view.")
				
				self.resetGameAr = true
				DispatchQueue.main.async {
					self.game.newGame()
					
					let encoder = JSONEncoder()
					if let data = try? encoder.encode(self.game) {
						UserDefaults.standard.set(data, forKey: "CurrentGame")
					}
				}
				
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("New Game")
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

//struct GameWonAndOver_Previews: PreviewProvider {
//    static var previews: some View {
//        GameWonAndOver()
//    }
//}
