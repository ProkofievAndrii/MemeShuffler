//
//  SettingsManager.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 29.07.2024.
//

import Foundation

public class SettingsManager {
    
    private enum Keys {
        //User experience
        static let showCensoredPosts = "showCensoredOrSpoilers"
        static let showSpoilerPosts = "showSpoilerPosts"
        static let allowVideoAutoplay = "allowVideoAutoplay"
        //Appearance
        static let interfaceTheme = "interfaceTheme"
        static let interfaceLanguage = "AppleLanguages"
        static let showFullMemeInfo = "showFullMemeInfo"
        //Data
        static let defaultSubreddit = "defaultSubreddit"
        static let defaultLoadingQuantity = "defaultLoadingQuantity"
    }
    
    //MARK: User experience
    public static var showCensoredPosts: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.showCensoredPosts)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showCensoredPosts)
        }
    }
    
    public static var showSpoilerPosts: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.showSpoilerPosts)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showSpoilerPosts)
        }
    }
    
    public static var allowVideoAutoplay: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.allowVideoAutoplay)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.allowVideoAutoplay)
        }
    }
    
    //MARK: Appearance
    public static var interfaceTheme: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.interfaceTheme)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.interfaceTheme)
        }
    }
    
    public static var interfaceLanguage: String {
        get {
            return UserDefaults.standard.array(forKey: Keys.interfaceLanguage)?.first as? String ?? "en"
        }
        set {
            UserDefaults.standard.set([newValue], forKey: Keys.interfaceLanguage)
        }
    }
    
    public static var showFullPostInfo: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.showFullMemeInfo)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showFullMemeInfo)
        }
    }
    
    //MARK: Data
    public static var defaultSubreddit: String {
        get {
            return  UserDefaults.standard.string(forKey: Keys.defaultSubreddit) ?? "memes"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.defaultSubreddit)
        }
    }
    
    public static var defaultLoadingQuantity: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.defaultLoadingQuantity)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.defaultLoadingQuantity)
        }
    }
}
