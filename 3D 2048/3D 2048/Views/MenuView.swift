//
//  MenuView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 12/01/2021.
//

import SwiftUI

struct MenuView: View {
	@EnvironmentObject var game: Game
	
	@State private var showingStatisticsView = false
	@State private var showingAboutView = false
	@State private var showingHowToPlayView = false
	@Binding var inPlayMode: Bool
	@Binding var focusEntityNeeded: Bool
	
	@Binding var highScore: Int
	@Binding var highestTile: Int
	@Binding var gamesWon: Int
	
	@Binding var launchedBefore: Bool
	
	var body: some View {
		ZStack {
			Color(UIColor.gray).opacity(0.75)
			VStack {
				Image("RoundedIcon")
					.resizable()
					.frame(width: 150, height: 150)
					.opacity(0.75)
					.padding()

				Text("3D 2048")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(.black)
					.opacity(0.75)
					.padding()
					.padding(.bottom)
				
				Button(action: {
					print("DEBUG: New game selected")
					
					self.inPlayMode = true
					self.focusEntityNeeded = true
				}) {
					Text("Play")
						.frame(width: 200, height: 60)
						.font(.title)
						.foregroundColor(.black)
						.background(Color.white)
						.opacity(0.75)
						.cornerRadius(30)
						.padding()
				}
				
				Button(action: {
					print("DEBUG: Statistics selected")
					
					self.showingStatisticsView.toggle()
				}) {
					Text("Statistics")
						.frame(width: 200, height: 60)
						.font(.title)
						.foregroundColor(.black)
						.background(Color.white)
						.opacity(0.75)
						.cornerRadius(30)
						.padding()
				}.sheet(isPresented: $showingStatisticsView, content: {
					StatisticsView(highScore: $highScore, highestTile: $highestTile, gamesWon: $gamesWon)
				})
				
				Button(action: {
					print("DEBUG: How to play selected")
					
					self.showingHowToPlayView.toggle()
				}) {
					Text("How to Play")
						.frame(width: 200, height: 60)
						.font(.title)
						.foregroundColor(.black)
						.background(Color.white)
						.opacity(0.75)
						.cornerRadius(30)
						.padding()
				}.sheet(isPresented: $showingHowToPlayView, content: {
					HowToPlayView(launchedBefore: $launchedBefore)
				})
				
				Button(action: {
					print("DEBUG: About selected")
					
					self.showingAboutView.toggle()
				}) {
					Text("About")
						.frame(width: 200, height: 60)
						.font(.title)
						.foregroundColor(.black)
						.background(Color.white)
						.opacity(0.75)
						.cornerRadius(30)
						.padding()
				}.sheet(isPresented: $showingAboutView, content: {
					AboutView().environmentObject(game)
				})
			}
		}
	}
}

//struct MenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        MenuView()
//    }
//}
