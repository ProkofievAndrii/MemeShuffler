//
//  ApiParametersManager.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 11.07.2024.
//

import Foundation
import CommonUtils

//MARK: - API handling
//Parameters manager for API request
class ApiParametersManager {
    //Variables
    private var subredditName: String = SettingsManager.defaultSubreddit
    private var quantity: Int = SettingsManager.defaultLoadingQuantity
    private var after: String? = nil
    private var filter: String = Filters.top.rawValue
    private var isInitial = true
    
    //Getters/Setters
    func getSubredditName() -> String {
        return subredditName
    }
    
    func setSubredditName(_ newName: String) {
        guard !newName.isEmpty else { return }
        subredditName = newName
    }
    
    func getQuantity() -> Int {
        return quantity
    }
    
    func setQuantity(_ newQuantity: Int) {
        guard newQuantity >= 0 else { return }
        quantity = newQuantity
    }
    
    func getAfter() -> String? {
        return after
    }
    
    func setAfter(_ newAfter: String?) {
        after = newAfter
    }
    
    func getFilter() -> String {
        return filter
    }
    
    func setFilter(_ newFilter: String) {
        filter = newFilter
    }
    
    func isInitialRequest() -> Bool {
        return isInitial
    }
    
    func setInitial(_ value: Bool) {
        isInitial = value
    }
}
