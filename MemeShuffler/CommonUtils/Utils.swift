//
//  Data Structures.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 06.07.2024.
//

import Foundation

//MARK: Data structures for parsing
//Nested structures (not being used)
public struct RedditResponce: Codable {
    public let data: ResponceData
}

public struct ResponceData: Codable {
    public let after: String?
    public let children: [DataChild]

    enum CodingKeys: String, CodingKey {
        case after
        case children
    }
}

public struct DataChild: Codable {
    public let data: Meme
}

public struct Meme: Codable {
    let subreddit:              String
    public let title:           String
    let authorFullname:         String?
    let downs, ups:             Int
    public let postHint:        String?
    public let over18, spoiler: Bool
    public let id:              String
    let author:                 String
    let numComments:            Int
    let permalink:              String
    public let urlString:       String?
    let createdUTC:             Int
    public let secureMedia:     SecureMedia?
    public var width:           Double = 0
    public var height:          Double = 0
    
    enum CodingKeys: String, CodingKey {
        case subreddit
        case authorFullname = "author_fullname"
        case title, downs, ups
        case postHint       = "post_hint"
        case over18         = "over_18"
        case spoiler, id, author
        case numComments    = "num_comments"
        case permalink
        case urlString      = "url"
        case createdUTC     = "created_utc"
        case secureMedia    = "secure_media"
    }
}

public extension Meme {
    init(
        id: String,
        title: String?,
        urlString: String?,
        width: Double,
        height: Double
    ) {
        self.subreddit       = ""
        self.authorFullname  = nil
        self.title           = title ?? ""
        self.downs           = 0
        self.ups             = 0
        self.postHint        = nil
        self.over18          = false
        self.spoiler         = false
        self.id              = id
        self.author          = ""
        self.numComments     = 0
        self.permalink       = ""
        self.urlString       = urlString
        self.createdUTC      = 0
        self.secureMedia     = nil
    }
}

public struct SecureMedia: Codable {
    public let redditVideo: RedditVideo?

    enum CodingKeys: String, CodingKey {
        case redditVideo = "reddit_video"
    }
}

public struct RedditVideo: Codable {
    public let height, width: Int
    public let fallbackUrl: URL
    public let dashUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case height, width
        case fallbackUrl = "fallback_url"
        case dashUrl = "dash_url"
    }
}

//MARK: - Enums
public enum Options: String, CaseIterable, EnumConvertible {
    case favoritePosts = "Favorite posts"
    case savedLocally = "Saved locally"
}

public enum Filters: String, CaseIterable, EnumConvertible {
    case top = "Top"
    case hot = "Hot"
    case new = "New"
}

public enum Themes: String, CaseIterable, EnumConvertible {
    case light = "Light"
    case dark = "Dark"
}

public enum Languages: String, CaseIterable, EnumConvertible {
    case english = "En"
    case ukrainian = "Uk"
}

//MARK: - Enum case/value convertion protocol
public protocol EnumConvertible: RawRepresentable, CaseIterable where RawValue: Equatable {
    static func caseFromValue(_ value: RawValue) -> Self?
}

public extension EnumConvertible {
    static func caseFromValue(_ value: RawValue) -> Self? {
        for currCase in Self.allCases {
            if currCase.rawValue == value {
                return currCase
            }
        }
        return nil
    }
}
