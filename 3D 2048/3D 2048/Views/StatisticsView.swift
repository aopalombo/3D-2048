//
//  StatisticsView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 09/01/2021.
//

import SwiftUI

struct StatisticsView: View {
	@Environment(\.presentationMode) var presentationMode
	
//	@State private var highScore = UserDefaults.standard.integer(forKey: "highScore") // Default start value = 0
//	@State private var highestTile = UserDefaults.standard.integer(forKey: "highestTile")
//	@State private var gamesWon = UserDefaults.standard.integer(forKey: "gamesWon")
	@Binding var highScore: Int
	@Binding var highestTile: Int
	@Binding var gamesWon: Int
	
    var body: some View {
		VStack {
			HStack {
				Spacer()
				
				Button(action: {
						self.presentationMode.wrappedValue.dismiss()
					
				}) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
						.font(.system(size: 25, weight: .bold))
						.padding([.top, .trailing])
				}
			}
			
			Text("Statistics")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundColor(.black)
				.minimumScaleFactor(0.8)
				.padding([.bottom, .leading, .trailing])
			
			HStack {
				Text("High Score")
					.font(.title2)
					.fontWeight(.bold)
					.padding()
				Text(String(highScore))
			}
			
			HStack {
				Text("Highest Tile")
					.font(.title2)
					.fontWeight(.bold)
					.padding()
				Text(String(highestTile))
			}
			
			HStack {
				Text("Games Won")
					.font(.title2)
					.fontWeight(.bold)
					.padding()
				Text(String(gamesWon))
			}
			
			Button(action: {
				highScore = 0
				highestTile = 0
				gamesWon = 0
//				UserDefaults.standard.set(0, forKey: "highScore")
//				UserDefaults.standard.set(0, forKey: "highestTile")
//				UserDefaults.standard.set(0, forKey: "gamesWon")
			}) {
				Text("Reset Statistics")
					.padding()
			}
			
			Spacer()
			
		}
		.background(Color(UIColor.systemBackground))
    }
}

//struct StatisticsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatisticsView()
//    }
//}
