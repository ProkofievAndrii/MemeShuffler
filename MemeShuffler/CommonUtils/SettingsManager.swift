//
//  SettingsManager.swift
//  CommonUtils
//
//  Created by Andrii Prokofiev on 29.07.2024.
//

import Foundation

public class SettingsManager {
    
    private enum Keys {
        static let defaultSubreddit = "defaultSubreddit"
        static let defaultLoadingQuantity = "defaultLoadingQuantity"
        static let showFullMemeInfo = "showFullMemeInfo"
        static let showCensoredOrSpoilers = "showCensoredOrSpoilers"
        static let autoplayVids = "autoplayVids"
        static let requestMode = "requestMode"
    }
    
    public static var defaultSubreddit: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.defaultSubreddit) ?? "memes"
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
    
    public static var showFullMemeInfo: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.showFullMemeInfo)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showFullMemeInfo)
        }
    }
    
    public static var showCensoredOrSpoilers: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.showCensoredOrSpoilers)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showCensoredOrSpoilers)
        }
    }
    
    public static var autoplayVids: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.autoplayVids)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.autoplayVids)
        }
    }
    
    
    public static var requestMode: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.requestMode)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.requestMode)
        }
    }
}
