//
//  MemeApiManager.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 06.07.2024.
//

import Foundation
import CommonUtils

public class MemeApiManager {
    
    //MARK: - Variables
    //Internal API parameters manager
    private static var parameters = ApiParametersManager()
    private static var currentTask: URLSessionDataTask?
    
    //MARK: - API request
    private static func requestMemesPortion(completion: @escaping ([Meme]?, Error?) -> Void) {
        let subreddit = parameters.getSubredditName()
        let quantity = parameters.getQuantity()
        let after = parameters.getAfter()
        let filter = parameters.getFilter().lowercased()
        
        var components = URLComponents(string: "https://www.reddit.com/r/\(subreddit)/\(filter).json?limit=\(quantity)")!
        guard after != nil || isInitialRequest() else { return }
        if after != nil {
            components.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        guard let url = components.url else {
            completion(nil, URLError(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error)")
                completion(nil, error)
                return
            }
            
            setInitial(false)
            
            guard let data = data else {
                completion(nil, URLError(.badServerResponse))
                return
            }
            
            do {
                let redditResponse = try JSONDecoder().decode(RedditResponce.self, from: data)
                let memes = redditResponse.data.children.map { $0.data }.filter { post in
                    let containsImageOrVideo = (post.postHint == "image" || post.postHint == "hosted:video")
                    let censorePassed = (SettingsManager.showCensoredPosts || !post.over18)
                    let spoilerPassed = (SettingsManager.showSpoilerPosts || !post.spoiler)
                    return containsImageOrVideo && censorePassed && spoilerPassed
                }
                setAfter(redditResponse.data.after)
                completion(memes, nil)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }


    //MARK: - Public methods for external usage
    //Request endpoint realization
    public static func loadMemesCompilation(completion: @escaping ([Meme]?) -> Void) {
        requestMemesPortion() { memes, error in
            if let error = error {
                print("Failed to load memes: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let memes = memes {
                completion(memes)
            } else {
                completion(nil)
            }
        }
    }
    
    // Parameters Getters/Setters
    public static func getSubredditName() -> String {
        return parameters.getSubredditName()
    }
    
    public static func setSubredditName(_ newName: String) {
        parameters.setSubredditName(newName)
    }
    
    public static func getQuantity() -> Int {
        return parameters.getQuantity()
    }
    
    public static func setQuantity(_ newQuantity: Int) {
        parameters.setQuantity(newQuantity)
    }
    
    public static func getAfter() -> String? {
        return parameters.getAfter()
    }
    
    public static func setAfter(_ newAfter: String?) {
        parameters.setAfter(newAfter)
    }
    
    public static func getFilter() -> String {
        return parameters.getFilter()
    }
    
    public static func setFilter(_ filter: String) {
        parameters.setFilter(filter)
    }
    
    public static func isInitialRequest() -> Bool {
        return parameters.isInitialRequest()
    }
    
    public static func setInitial(_ value: Bool) {
        parameters.setInitial(value)
    }
}
