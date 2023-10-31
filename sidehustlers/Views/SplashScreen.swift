//
//  SplashScreen.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-31.
//

import SwiftUI

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct SplashScreen: View {
    @State private var isActive = false
    @State private var isTransitioning = false

    var body: some View {
        ZStack {
            // Set the background color
            Color(UIColor(hex: "#F2F0E2"))
                .ignoresSafeArea()

            // Create a VStack to center the image vertically
            VStack {
                Spacer() // Pushes the image to the center vertically

                // Display the full-screen image as the background with fade-in and fade-out animations
                Image("splashscreen") // Replace "splashscreen" with the name of your image asset
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(isActive && !isTransitioning ? 1 : 0) // Initially hidden
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0)) {
                            isActive = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                isTransitioning = true
                            }
                        }
                    }

                Spacer() // Pushes the image to the center vertically
            }
        }
        .onAppear {
            // Add a delay and then set `isActive` to true to transition to the main content view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isActive = true
            }
        }
    }
}
