//
//  CameraAccessDeniedView.swift
//  3D 2048
//
//  Created by Andrew Palombo on 16/01/2021.
//

import SwiftUI

struct CameraAccessDeniedView: View {
    var body: some View {
		VStack {
			Text("Camera Access Denied")
				.font(.largeTitle)
				.fontWeight(.bold)
				.padding()
			
			Text("Camera access is needed to place AR objects in the world.")
				.font(.body)
				.multilineTextAlignment(.center)
				.padding()
			Text("No data is gathered or sent from your device.")
				.font(.body)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
				.padding()
			Text("From settings, tap '3D 2048', then toggle on camera access.")
				.font(.body)
				.multilineTextAlignment(.center)
				.padding()
			Spacer()
			
			Button(action: {
				print("DEBUG: Open settings selected from camera access denied view.")
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
			}) {
				Text("Open Settings")
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

struct CameraAccessDeniedView_Previews: PreviewProvider {
    static var previews: some View {
        CameraAccessDeniedView()
    }
}
