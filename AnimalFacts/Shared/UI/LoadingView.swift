//
//  LoadingView.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import SwiftUI

struct LoadingView: View {
    let text: String
    @State private var isAnimating = false
    
    init(_ text: String = "Loading...") {
        self.text = text
    }
    
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.white, lineWidth: 8)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear { isAnimating = true }
            
            Text(LocalizedStringKey(text))
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .edgesIgnoringSafeArea(.all)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
        LoadingView("Custom loading message")
    }
}
