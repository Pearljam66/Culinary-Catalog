//
//  RecipeDataRepositoryTests.swift
//  CulinaryCatalogTests
//
//  Created by Sarah Clark on 2/4/25.
//

import CoreData
import Network
import Testing
@testable import CulinaryCatalog

struct RecipeDataRepositoryTests {

    private let mockNetworkManager = MockNetworkManager()

    private func clearCoreData(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest = Recipe.fetchRequest()
                let objects = try context.fetch(fetchRequest)
                for object in objects {
                    context.delete(object)
                }
                try context.save()
            } catch {
                print("Error clearing Core Data: \(error)")
            }
        }
    }

    @Test func testFetchRecipes() async throws {
        let coreDataController = CoreDataController(.inMemory)
        let repository = RecipeDataRepository(networkManager: mockNetworkManager, viewContext: coreDataController.persistentContainer.viewContext)

        seedCoreDataWithMockData(context: coreDataController.persistentContainer.viewContext)

        let recipes = try await repository.fetchRecipes()

        #expect(recipes.count == 10)
        #expect(recipes.first?.recipeName == "BeaverTails")

        clearCoreData(context: coreDataController.persistentContainer.viewContext)
    }

    @Test func testRefreshRecipes() async throws {
        let coreDataController = CoreDataController(.inMemory)
        let repository = RecipeDataRepository(networkManager: mockNetworkManager, viewContext: coreDataController.persistentContainer.viewContext)

        seedCoreDataWithMockData(context: coreDataController.persistentContainer.viewContext)

        // Mock network fetch to return a single recipe, different from what's in Core Data
        mockNetworkManager.mockRecipes = [
            RecipeModel(
                cuisineType: "Malaysian",
                recipeName: "Apam Balik",
                photoLarge: "someURL",
                photoSmall: "someURL",
                sourceURL: "someURL",
                id: UUID(uuidString: "0c6ca6e7-e32a-4053-b824-1dbf749910d8")!,
                youTubeURL: "someURL"
            )
        ]

        let refreshedRecipes = try await repository.refreshRecipes()

        #expect(refreshedRecipes.count == 1)
        #expect(refreshedRecipes.first?.recipeName == "Apam Balik")

        // Check if the data in Core Data has changed to match the mock recipe
        let fetchRequest: NSFetchRequest = Recipe.fetchRequest()
        let fetchedEntities = try coreDataController.persistentContainer.viewContext.fetch(fetchRequest)
        #expect(fetchedEntities.count == 1)
        #expect(fetchedEntities.first?.recipeName == "Apam Balik")

        clearCoreData(context: coreDataController.persistentContainer.viewContext)
    }

    @Test func testRefreshRecipesError() async throws {
        let coreDataController = CoreDataController(.inMemory)
        let repository = RecipeDataRepository(networkManager: mockNetworkManager, viewContext: coreDataController.persistentContainer.viewContext)

        mockNetworkManager.shouldThrowError = true

        do {
            _ = try await repository.refreshRecipes()
            #expect(Bool(false)) // Should not reach here if an error is thrown
        } catch {
            #expect(Bool(true)) // An error should have been thrown
        }

        // Check if Core Data remains empty since refresh didn't complete
        let fetchRequest: NSFetchRequest = Recipe.fetchRequest()
        let fetchedEntities = try coreDataController.persistentContainer.viewContext.fetch(fetchRequest)
        #expect(fetchedEntities.isEmpty == true)

        clearCoreData(context: coreDataController.persistentContainer.viewContext)
    }

    private func seedCoreDataWithMockData(context: NSManagedObjectContext) {
        for _ in 0..<10 {
            let newRecipe = Recipe(context: context)
            newRecipe.id = UUID()
            newRecipe.cuisineType = "Canadian"
            newRecipe.recipeName = "BeaverTails"
            newRecipe.photoSmall = "mockPhotoSmall"
            newRecipe.photoLarge = "mockPhotoLarge"
            newRecipe.sourceURL = "mockSourceURL"
            newRecipe.youTubeURL = "mockYouTubeURL"
        }
        do {
            try context.save()
        } catch {
            print("Error saving mock data: \(error)")
        }
    }

}
