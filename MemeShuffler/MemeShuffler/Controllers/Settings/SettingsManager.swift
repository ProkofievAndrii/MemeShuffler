//
//  SettingsManager.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 29.07.2024.
//

import Foundation

public class SettingsManager {
    
    private enum Keys {
        // User experience
        static let showCensoredPosts       = "showCensoredOrSpoilers"
        static let showSpoilerPosts        = "showSpoilerPosts"
        static let allowVideoAutoplay      = "allowVideoAutoplay"
        // Appearance
        static let interfaceTheme          = "interfaceTheme"
        static let interfaceLanguage       = "AppleLanguages"
        static let showFullMemeInfo        = "showFullMemeInfo"
        // API parameters
        static let defaultSubreddit        = "defaultSubreddit"
        static let defaultLoadingQuantity  = "defaultLoadingQuantity"
        // Database parameters
        static let localSaveLimit          = "localSaveLimit"
        // Custom subreddits
        static let savedSubreddits         = "savedSubreddits"
    }
    
    // MARK: - User experience
    
    public static var showCensoredPosts: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.showCensoredPosts) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.showCensoredPosts) }
    }
    
    public static var showSpoilerPosts: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.showSpoilerPosts) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.showSpoilerPosts) }
    }
    
    public static var allowVideoAutoplay: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.allowVideoAutoplay) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.allowVideoAutoplay) }
    }
    
    // MARK: - Appearance
    
    public static var interfaceTheme: Int {
        get { UserDefaults.standard.integer(forKey: Keys.interfaceTheme) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.interfaceTheme) }
    }
    
    public static var interfaceLanguage: String {
        get {
            UserDefaults.standard
                .array(forKey: Keys.interfaceLanguage)?
                .first as? String ?? "en"
        }
        set {
            UserDefaults.standard.set([newValue], forKey: Keys.interfaceLanguage)
        }
    }
    
    public static var showFullPostInfo: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.showFullMemeInfo) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.showFullMemeInfo) }
    }
    
    // MARK: - API parameters
    public static var defaultSubreddit: String {
        get { UserDefaults.standard.string(forKey: Keys.defaultSubreddit) ?? "memes" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.defaultSubreddit) }
    }
    
    public static var defaultLoadingQuantity: Int {
        get { UserDefaults.standard.integer(forKey: Keys.defaultLoadingQuantity) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.defaultLoadingQuantity) }
    }
    
    public static var localSaveLimit: Int {
        get { UserDefaults.standard.integer(forKey: Keys.localSaveLimit) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.localSaveLimit) }
    }
    
    // MARK: - Custom Subreddits
    private static let defaultSubredditsList = ["memes"]
    
    public static var savedSubreddits: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: Keys.savedSubreddits)
                ?? defaultSubredditsList
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.savedSubreddits)
        }
    }
    
    public static func addSubreddit(_ subreddit: String) {
        let clean = subreddit
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        
        var list = savedSubreddits
        guard !list.contains(clean) else { return }
        
        list.append(clean)
        savedSubreddits = list
    }

    public static func removeSubreddit(at index: Int) {
        var list = savedSubreddits
        guard list.indices.contains(index) else { return }
        
        list.remove(at: index)
        savedSubreddits = list
    }
}
