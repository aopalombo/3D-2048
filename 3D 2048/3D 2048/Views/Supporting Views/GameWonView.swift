//
//  GameWonView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 15/01/2021.
//

import SwiftUI

struct GameWonView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var game: Game
	
	@Binding var resetGameAr: Bool
	
    var body: some View {
		VStack {
			Text("Game Won!")
				.font(.largeTitle)
				.fontWeight(.bold)
				.padding()
			Text("You can keep playing to score even higher.")
				.font(.body)
				.padding()
			Text("So far you've scored \(String(game.score)) in \(String(game.minutes)) minute(s) \(String(game.seconds)) second(s) with \(String(game.moves)) moves.")
				.font(.body)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
				.padding()
			Spacer()
			
			Button(action: {
				print("DEBUG: New game selected from game won view.")
				
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
					.foregroundColor(.black)
					.font(.headline)
					.cornerRadius(15)
					.padding()
			}
			
			Button(action: {
				print("DEBUG: Keep playing selected from game won view.")
				self.presentationMode.wrappedValue.dismiss()
				
				game.startStopwatch()
			}) {
				Text("Keep Playing")
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

//struct GameWonView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameWonView()
//    }
//}
