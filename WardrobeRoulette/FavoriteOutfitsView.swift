//
//  FavoriteOutfitsView.swift
//  WardrobeRoulette
//
//  Created by Fayben on 6/28/25.
//

import SwiftUI

struct FavoriteOutfitsView: View {
    var outfits: [[String: UIImage]]
    var onDelete: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    let categories = ["Tops", "Bottoms", "Shoes", "Jackets", "Hats"]
    let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        NavigationView {
            List {
                ForEach(outfits.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("Outfit \(index + 1)")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(categories, id: \.self) { category in
                                if let image = outfits[index][category] {
                                    VStack {
                                        Text(category)
                                            .font(.caption)
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 70, height: 70)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        Button("Delete Outfit") {
                            onDelete(index)
                        }
                        .foregroundColor(.red)
                        .padding(.top, 5)
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorite Outfits")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
