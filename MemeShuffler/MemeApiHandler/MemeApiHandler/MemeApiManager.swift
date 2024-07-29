//
//  MemeApiManager.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 06.07.2024.
//

import Foundation

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
        
        var components = URLComponents(string: "https://www.reddit.com/r/\(subreddit)/top.json?limit=\(quantity)")!
        if after != nil {
            components.queryItems?.append(URLQueryItem(name: "after", value: after))
        }
        
        guard let url = components.url else {
            completion(nil, URLError(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, URLError(.badServerResponse))
                return
            }
            
            do {
                let redditResponse = try JSONDecoder().decode(RedditResponce.self, from: data)
                parameters.setAfter(redditResponse.data.after ?? String())
                let memes = redditResponse.data.children.map { $0.data }.filter {
                    $0.postHint == "image" || $0.postHint == "hosted:video"
                }
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
}
