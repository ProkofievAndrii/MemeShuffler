//
//  Data Structures.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 06.07.2024.
//

import Foundation

//MARK: Data structures for parsing
//Nested structures (not being used)
// MARK: - Welcome
struct RedditResponce: Codable {
    let data: ResponceData
}

// MARK: - WelcomeData
struct ResponceData: Codable {
    let after: String?
    let children: [DataChild]

    enum CodingKeys: String, CodingKey {
        case after
        case children
    }
}

// MARK: - Child
struct DataChild: Codable {
    let data: Meme
}

// MARK: - Meme
public struct Meme: Codable {
    let subreddit, authorFullname, title: String
    let downs, ups: Int
    public let postHint: String?
    let over18, spoiler: Bool
    let id, author: String
    let numComments: Int
    let permalink: String
    public let urlString: String?
    let createdUTC: Int
    public let secureMedia: SecureMedia?
    
    enum CodingKeys: String, CodingKey {
        case subreddit
        case authorFullname = "author_fullname"
        case title, downs, ups
        case postHint = "post_hint"
        case over18 = "over_18"
        case spoiler, id, author
        case numComments = "num_comments"
        case permalink
        case urlString = "url"
        case createdUTC = "created_utc"
        case secureMedia = "secure_media"
    }
}

// MARK: - SecureMedia
public struct SecureMedia: Codable {
    public let redditVideo: RedditVideo?

    enum CodingKeys: String, CodingKey {
        case redditVideo = "reddit_video"
    }
}

// MARK: - RedditVideo
public struct RedditVideo: Codable {
    public let height, width: Int
    public let fallbackUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case height, width
        case fallbackUrl = "fallback_url"
    }
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
