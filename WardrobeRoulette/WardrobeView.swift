import SwiftUI

struct WardrobeView: View {
    var categories: [String]
    var onSelectCategory: (String) -> Void
    var onClose: () -> Void
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        onSelectCategory(category)
                    }
                    .padding()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("My Wardrobe")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onClose()
                    }
                }
            }
        }
    }
}
