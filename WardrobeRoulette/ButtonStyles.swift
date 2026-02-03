//
//  ButtonStyles.swift
//  WardrobeRoulette
//
//  Created by Fayben on 6/28/25.
//

// ButtonStyles.swift
import SwiftUI

extension View {
    func buttonStyleMain() -> some View {
        self
            .padding()
           // .frame(maxWidth: .infinity)
            .background(Color("ButtonColor"))
            .foregroundColor(.white)
            .cornerRadius(12)
    }
    
    func buttonStyleTryAgain() -> some View {
        self
            .font(.caption)
            .padding(5)
            .background(Color("ButtonColor"))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    func buttonStylePlain() -> some View {
        self
            .padding(10)
            .background(Color.clear)
    }
}
