//
//  WardrobeCategoryView.swift
//  WardrobeRoulette
//
//  Created by Fayben on 6/28/25.
//

import SwiftUI

struct WardrobeCategoryView: View {
    var category: String
    var images: [UIImage]
    var onDelete: (Int) -> Void
    var onClose: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        VStack {
            Text(category)
                .font(.custom("Ad Lib", size: 28))
                .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(images.indices, id: \.self) { index in
                        VStack {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Button("Delete") {
                                onDelete(index)
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Button("Back") {
                onClose()
            }
            .padding()
        }
        .padding()
    }
}
