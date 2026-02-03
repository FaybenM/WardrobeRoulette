import SwiftUI
import PhotosUI

struct ContentView: View {
    // MARK: - Image Selection & Wardrobe State
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var tempSelectedImages: [UIImage] = [] // NEW: hold before "Add"
    @State private var imagesToCategorize: [UIImage] = []
    @State private var currentImageToCategorize: UIImage?
    @State private var showCategoryPrompt = false
    @State private var showWardrobe = false
    @State private var selectedFolder: String? = nil
    @State private var showFavorites = false

    @State private var tops: [UIImage] = []
    @State private var bottoms: [UIImage] = []
    @State private var hats: [UIImage] = []
    @State private var shoes: [UIImage] = []
    @State private var jackets: [UIImage] = []

    @State private var currentOutfit: [String: UIImage] = [:]
    @State private var favoriteOutfits: [[String: UIImage]] = []

    let categories = ["Tops", "Bottoms", "Shoes", "Jackets", "Hats"]
    let columns = [GridItem(.fixed(130)), GridItem(.fixed(130)), GridItem(.fixed(130))]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Wardrobe Roulette")
                        .font(.custom("Ad Lib", size: 34))
                        .foregroundColor(Color("TitleColor"))

                    // MARK: Photos Picker
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 0, matching: .images) {
                        Label("Select Clothing Images", systemImage: "photo")
                            .buttonStyleMain()
                    }
                    .onChange(of: selectedItems) { _, newItems in
                        tempSelectedImages.removeAll()
                        newItems.forEach(loadTempImage) // load into temp
                    }

                    // NEW: Show Add button if temp images exist
                    if !tempSelectedImages.isEmpty {
                        Button("Add") {
                            imagesToCategorize.append(contentsOf: tempSelectedImages)
                            tempSelectedImages.removeAll()
                            if !showCategoryPrompt {
                                showNextImagePrompt()
                            }
                        }
                        .buttonStyleMain()
                    }

                    // MARK: Outfit Grid
                    LazyVGrid(columns: columns, spacing: 30) {
                        emptySlot()
                        clothingSlot("Tops")
                        clothingSlot("Jackets")
                        clothingSlot("Hats")
                        clothingSlot("Bottoms")
                        emptySlot()
                        emptySlot()
                        clothingSlot("Shoes")
                        emptySlot()
                    }
                    .padding()

                    // MARK: Dress Me + Favorite
                    VStack(spacing: 10) {
                        Button(action: saveCurrentOutfit) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        .buttonStylePlain()
                        .accessibilityLabel("Save Outfit to Favorites")

                        Button(action: generateOutfit) {
                            Text("Dress Me")
                        }
                        .buttonStyleMain()
                    }

                    // MARK: Current Outfit Preview
                    if !currentOutfit.isEmpty {
                        Text("Your Outfit")
                            .font(.headline)

                        HStack {
                            ForEach(categories, id: \.self) { category in
                                if let image = currentOutfit[category] {
                                    VStack {
                                        Text(category)
                                            .font(.caption)
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 70, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }

                        HStack {
                            ForEach(categories, id: \.self) { category in
                                Button("Try Again \(category)") {
                                    tryAgain(category: category)
                                }
                                .buttonStyleTryAgain()
                            }
                        }
                    }

                    // MARK: Wardrobe & Favorites Buttons
                    Button("My Wardrobe") {
                        showWardrobe.toggle()
                    }
                    .buttonStyleMain()

                    Button("Favorites") {
                        showFavorites.toggle()
                    }
                    .buttonStyleMain()
                }
                .padding()
                .background(Color("BackgroundColor").ignoresSafeArea())
                .sheet(isPresented: $showCategoryPrompt, onDismiss: showNextImagePrompt) {
                    if let image = currentImageToCategorize {
                        categoryPromptSheet(for: image)
                    }
                }
                .sheet(isPresented: $showWardrobe) {
                    if let folder = selectedFolder {
                        WardrobeCategoryView(
                            category: folder,
                            images: getImages(for: folder),
                            onDelete: { index in deleteItem(from: folder, at: index) },
                            onClose: {
                                showWardrobe = false
                                selectedFolder = nil
                            }
                        )
                    } else {
                        WardrobeView(
                            categories: categories,
                            onSelectCategory: { selectedFolder = $0 },
                            onClose: { showWardrobe = false }
                        )
                    }
                }
                .sheet(isPresented: $showFavorites) {
                    FavoriteOutfitsView(
                        outfits: favoriteOutfits,
                        onDelete: { index in favoriteOutfits.remove(at: index) }
                    )
                }
                .navigationBarHidden(true)
            }
        }
    }

    // MARK: - Subviews & Sheets
    @ViewBuilder
    func categoryPromptSheet(for image: UIImage) -> some View {
        VStack(spacing: 20) {
            Text("Which category is this?")
                .font(.title3)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            ForEach(categories, id: \.self) { category in
                Button(category) {
                    addImageToCategory(image: image, category: category)
                    showNextImagePrompt()
                }
                .buttonStyleMain()
            }
        }
        .padding()
    }

    func clothingSlot(_ category: String) -> some View {
        VStack {
            Text(category)
                .font(.caption)
                .foregroundColor(.white)

            ZStack {
                Image("leopard")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .cornerRadius(12)

                if let image = currentOutfit[category] {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 100, height: 100)
                }
            }
        }
    }

    func emptySlot() -> some View {
        Color.clear.frame(width: 130, height: 150)
    }

    // MARK: - Image & Wardrobe Functions
    func getImages(for category: String) -> [UIImage] {
        switch category {
        case "Tops": return tops
        case "Bottoms": return bottoms
        case "Hats": return hats
        case "Shoes": return shoes
        case "Jackets": return jackets
        default: return []
        }
    }

    func deleteItem(from category: String, at index: Int) {
        switch category {
        case "Tops": tops.remove(at: index)
        case "Bottoms": bottoms.remove(at: index)
        case "Hats": hats.remove(at: index)
        case "Shoes": shoes.remove(at: index)
        case "Jackets": jackets.remove(at: index)
        default: break
        }
    }

    // NEW: load into temp first
    func loadTempImage(item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            if case .success(let data?) = result, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    tempSelectedImages.append(image)
                    print("DEBUG: tempSelectedImages count = \(tempSelectedImages.count)")
                }
            }
        }
    }

    func showNextImagePrompt() {
        if !imagesToCategorize.isEmpty {
            currentImageToCategorize = imagesToCategorize.removeFirst()
            DispatchQueue.main.async {
                showCategoryPrompt = true
                print("Showing category prompt for next image. Remaining queue: \(imagesToCategorize.count)")
            }
        } else {
            showCategoryPrompt = false
        }
    }

    func addImageToCategory(image: UIImage, category: String) {
        switch category {
        case "Tops": tops.append(image)
        case "Bottoms": bottoms.append(image)
        case "Hats": hats.append(image)
        case "Shoes": shoes.append(image)
        case "Jackets": jackets.append(image)
        default: break
        }
    }

    // MARK: - Outfit Functions
    func generateOutfit() {
        guard let top = tops.randomElement(),
              let bottom = bottoms.randomElement(),
              let hat = hats.randomElement(),
              let shoe = shoes.randomElement(),
              let jacket = jackets.randomElement() else { return }

        currentOutfit = [
            "Tops": top,
            "Bottoms": bottom,
            "Hats": hat,
            "Shoes": shoe,
            "Jackets": jacket
        ]
    }

    func tryAgain(category: String) {
        let newImage: UIImage?
        switch category {
        case "Tops": newImage = tops.randomElement()
        case "Bottoms": newImage = bottoms.randomElement()
        case "Hats": newImage = hats.randomElement()
        case "Shoes": newImage = shoes.randomElement()
        case "Jackets": newImage = jackets.randomElement()
        default: newImage = nil
        }
        if let image = newImage {
            currentOutfit[category] = image
        }
    }

    func saveCurrentOutfit() {
        if !currentOutfit.isEmpty {
            favoriteOutfits.append(currentOutfit)
        }
    }
}
