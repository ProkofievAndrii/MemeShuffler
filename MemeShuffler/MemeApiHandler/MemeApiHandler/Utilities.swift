//
//  Data Structures.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 06.07.2024.
//

import Foundation

//MARK: Data structures for parsing
struct Root: Codable {
    let count: Int
    let memes: [Meme]
}

// MARK: - Meme
public struct Meme: Codable {
    let postLink: String
    let subreddit, title: String
    let url: String
    let nsfw, spoiler: Bool
    let author: String
    let ups: Int
    let preview: [String]
}

//MARK: - Utils
//Enumeration containing default subreddit cases used by application
public enum Subreddits: String, CaseIterable {
    //Cases
    case angryupvote = "angryupvote"
    case blursedimages = "blursedimages"
    case cursedcomments = "cursedcomments"
    case deadbydaylight = "deadbydaylight"
    case greentext = "greentext"
    case shitposting = "shitposting"
    
    //Functions
    public static func getRandomSubreddit() -> Subreddits {
        return Subreddits.allCases.randomElement() ?? .deadbydaylight
    }
    
    public static func getRandomSubredditGroup(subredditNum: Int) -> [Subreddits] {
        guard subredditNum > 0, subredditNum <= Subreddits.allCases.count else {
            return Array(Subreddits.allCases.prefix(subredditNum))
        }
        
        var chosenSubreddits: Set<Subreddits> = []
        while chosenSubreddits.count < subredditNum {
            chosenSubreddits.insert(getRandomSubreddit())
        }
        
        return Array(chosenSubreddits)
    }
}
