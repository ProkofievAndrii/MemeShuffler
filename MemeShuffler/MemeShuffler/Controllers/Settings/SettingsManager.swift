//
//  SettingsManager.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 29.07.2024.
//

import Foundation

class SettingsManager {
    
    private enum Keys {
        static let defaultSubreddit = "defaultSubreddit"
        static let defaultLoadingQuantity = "defaultLoadingQuantity"
        static let showFullMemeInfo = "showFullMemeInfo"
        static let showCensoredOrSpoilers = "showCensoredOrSpoilers"
        static let autoplayVids = "autoplayVids"
    }
    
    static var defaultSubreddit: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.defaultSubreddit) ?? "memes"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.defaultSubreddit)
        }
    }
    
    static var defaultLoadingQuantity: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.defaultLoadingQuantity)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.defaultLoadingQuantity)
        }
    }
    
    static var showFullMemeInfo: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.showFullMemeInfo)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showFullMemeInfo)
        }
    }
    
    static var showCensoredOrSpoilers: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.showCensoredOrSpoilers)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showCensoredOrSpoilers)
        }
    }
    
    static var autoplayVids: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.autoplayVids)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.autoplayVids)
        }
    }
}
