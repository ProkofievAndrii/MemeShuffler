//
//  Data Structures.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 06.07.2024.
//

import Foundation

//MARK: - API handling data structures
//Parameters for API request
struct ApiParameters {
    static var subredditName: String = String()
    static var quantity: Int = Int()
}

//Meme structure for parsing
struct Meme: Codable {
    let postLink: String
    let subreddit: String
    let title: String
    let url: String
}

//MARK: - Utils
//Subreddits enumeration
enum Subreddits: String {
    case angryupvote = "angryupvote"
    case blursedimages = "blursedimages"
    case cursedcomments = "cursedcomments"
    case deadbydaylight = "deadbydaylight"
    case greentext = "greentext"
    case shitposting = "shitposting"
    
    public func getRandomSubredditGroup(subredditNum: Int) {
        var chosenSubreddits: [Subreddits] = []
        while chosenSubreddits.count < subredditNum {

        }
    }
}
