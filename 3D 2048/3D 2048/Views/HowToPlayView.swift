//
//  HowToPlayView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 16/01/2021.
//

import SwiftUI

struct HowToPlayView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@Binding var launchedBefore: Bool {
		didSet {
			UserDefaults.standard.set(true, forKey: "LaunchedBefore")
		}
	}
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				
				Button(action: {
					launchedBefore = true
					
					self.presentationMode.wrappedValue.dismiss()
					
				}) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
						.font(.system(size: 25, weight: .bold))
						.padding([.top, .trailing])
				}
			}
			
			Text("How to Play")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundColor(.black)
				.padding([.bottom, .leading, .trailing])
			
			Text("Inspired by the original 2048 game by Gabriele Cirulli.")
				.font(.body)
				.multilineTextAlignment(.center)
				.padding()
			
			ScrollView {
				VStack(alignment: .leading) {
					HStack {
						Image(systemName: "circlebadge.fill")
							.padding()
						Text("The game starts with two randomly placed tiles, and new tiles are placed after each move.")
							.font(.body)
							.fontWeight(.bold)
							.multilineTextAlignment(.leading)
							.padding()
					}
					HStack {
						Image(systemName: "circlebadge.fill")
							.padding()
						Text("Use the arrows to move the tiles - the diagonal arrows move tiles in 3D towards and away from the front of the grid.")
							.font(.body)
							.fontWeight(.bold)
							.multilineTextAlignment(.leading)
							.padding()
					}
					HStack {
						Image(systemName: "circlebadge.fill")
							.padding()
						Text("When two tiles of the same value collide, they combine to make a new tile of double that value.")
							.font(.body)
							.fontWeight(.bold)
							.multilineTextAlignment(.leading)
							.padding()
					}
				}
				
			}.frame(minWidth: 100, idealWidth: 300, maxWidth: 400, alignment: .leading)
			
			Spacer()
			
		}
		.background(Color(UIColor.systemBackground))
	}
}

//struct HowToPlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        HowToPlayView()
//    }
//}
