//
//  RecipeDetailView.swift
//  CulinaryCatalog
//
//  Created by Sarah Clark on 1/27/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeDetailViewModel

    init(recipe: RecipeModel) {
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: viewModel.recipe.photoLarge)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .clipped()
                } placeholder: {
                    ProgressView()
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                }

                if let url = URL(string: viewModel.recipe.sourceURL) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "link")
                            Text("View Original Recipe")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(viewModel.recipe.recipeName)
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        Text(viewModel.countryFlag(for: viewModel.recipe.cuisineType))
                            .font(.largeTitle)
                    }

                    Spacer()

                    if let videoID = viewModel.youtubeVideoID {
                        VStack {
                            Text("Recipe Video")
                                .font(.headline)
                                .padding(.top)

                            YouTubeVideoView(videoID: videoID)
                                .frame(height: 250)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview("Light Mode") {
    let sampleRecipe = RecipeModel(
        cuisineType: "British",
        recipeName: "Apple & Blackberry Crumble",
        photoLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg",
        photoSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg",
        sourceURL: "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
        id: UUID(),
        youTubeURL: "https://www.youtube.com/watch?v=4vhcOwVBDO4"
    )

    RecipeDetailView(recipe: sampleRecipe)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let sampleRecipe = RecipeModel(
        cuisineType: "British",
        recipeName: "Apple & Blackberry Crumble",
        photoLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg",
        photoSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg",
        sourceURL: "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
        id: UUID(),
        youTubeURL: "https://www.youtube.com/watch?v=4vhcOwVBDO4"
    )

    RecipeDetailView(recipe: sampleRecipe)
        .preferredColorScheme(.dark)
}
