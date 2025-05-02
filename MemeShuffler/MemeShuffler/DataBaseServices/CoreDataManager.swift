//
//  CoreDataManager.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 28.04.2025.
//

import Foundation
import CoreData
import CommonUtils

final class CoreDataManager {
    // MARK: - Singleton
    static let shared = CoreDataManager()

    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MemeShuffler")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save Context
    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("CoreData Save Error: \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - CRUD Operations
    func fetchPost(withId id: String) -> Post? {
        let req: NSFetchRequest<Post> = Post.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id)
        req.fetchLimit = 1
        do {
            return try viewContext.fetch(req).first
        } catch {
            print("Fetch post by id failed: \(error)")
            return nil
        }
    }
    
    func fetchAllPosts() -> [Post] {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch all posts failed: \(error)")
            return []
        }
    }

    func fetchFavoritePosts() -> [Post] {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch favorite posts failed: \(error)")
            return []
        }
    }

    func deleteAllPosts() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(deleteRequest)
            viewContext.reset()
        } catch {
            print("Failed to delete all posts:", error)
        }
    }

    func delete(post: Post) {
        viewContext.delete(post)
        saveContext()
    }

    func deletePost(withId id: String) {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try viewContext.fetch(request)
            for post in results {
                viewContext.delete(post)
            }
            saveContext()
        } catch {
            print("Failed to delete post with id \(id): \(error)")
        }
    }

    // MARK: - Favorite Handling
    func isFavorite(id: String) -> Bool {
        let req: NSFetchRequest<Post> = Post.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@ AND isFavorite == YES", id)
        return (try? viewContext.count(for: req)) ?? 0 > 0
    }

    func favorite(
        meme: Meme,
        mediaData: Data,
        mediaType: String,
        width: Double,
        height: Double
    ) {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", meme.id)

        let post: Post
        if let existing = (try? viewContext.fetch(request))?.first {
            post = existing
        } else {
            post = Post(context: viewContext)
            post.id        = meme.id
            post.title     = meme.title
            post.urlString = meme.urlString
            post.width     = meme.width
            post.height    = meme.height
        }
        post.isFavorite = true
        post.mediaData  = mediaData
        post.mediaType  = mediaType
        saveContext()
    }

    func unfavorite(id: String) {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let post = (try? viewContext.fetch(request))?.first {
            post.isFavorite = false
            saveContext()
        }
    }
}
