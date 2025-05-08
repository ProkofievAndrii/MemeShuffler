//
//  AppDelegate.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import CoreData
import BackgroundTasks
import MemeApiHandler
import CommonUtils
import Kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Background Fetch Identifier
    private let refreshTaskIdentifier = "ua.edu.ukma.Prokofiev.MemeShuffler.apprefresh"

    // MARK: - UIApplicationDelegate

    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "subredditsInitialized") {
            let initial = SettingsManager.defaultSubreddit
            defaults.set([initial], forKey: "savedSubreddits")
            defaults.set(true, forKey: "subredditsInitialized")
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        scheduleAppRefresh()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }

    func application(
      _ application: UIApplication,
      configurationForConnecting connectingSceneSession: UISceneSession,
      options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
      _ application: UIApplication,
      didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {

    }

    // MARK: - Memory Warning Handler
    @objc private func didReceiveMemoryWarning() {
        ImageCache.default.clearMemoryCache()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - BackgroundTasks Scheduling
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 60 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        task.expirationHandler = {
        }

        MemeApiManager.loadMemesCompilation { memes in
            let success: Bool

            if let memes = memes, !memes.isEmpty {
                let context = self.persistentContainer.viewContext
                do {
                    try context.save()
                    success = true
                } catch {
                    print("Background fetch save error: \(error)")
                    success = false
                }
            } else {
                success = false
            }

            task.setTaskCompleted(success: success)
        }
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MemeShuffler")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved Core Data save error: \(nserror), \(nserror.userInfo)")
        }
    }
}
