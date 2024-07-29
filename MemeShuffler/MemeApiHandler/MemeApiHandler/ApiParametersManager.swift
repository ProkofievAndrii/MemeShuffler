//
//  ApiParametersManager.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 11.07.2024.
//

import Foundation

//MARK: - API handling
//Parameters manager for API request
class ApiParametersManager {
    //Variables
    private var subredditName: String = "deadbydaylight"
    private var quantity: Int = 10
    private var after: String? = nil
    
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
}
