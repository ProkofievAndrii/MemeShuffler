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
    private static func requestMemesPortion(page: Int, completion: @escaping ([Meme]?, Error?) -> Void) {
            var components = URLComponents(string: "https://meme-api.com/gimme")!
            components.path += "/\(parameters.getSubredditName())/\(parameters.getQuantity())"
            
            guard let url = components.url else {
                completion(nil, URLError(.badURL))
                return
            }
            
            currentTask?.cancel()
            currentTask = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error as? URLError, error.code != .cancelled {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, URLError(.badServerResponse))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let memeResponse = try decoder.decode(Root.self, from: data)
                    completion(memeResponse.memes, nil)
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                    completion(nil, error)
                }
            }
            currentTask?.resume()
        }

    //MARK: - Public methods for external usage
    //Request endpoint realization
        public static func loadMemesCompilation(page: Int = 1, completion: @escaping ([Meme]?) -> Void) {
            requestMemesPortion(page: page) { memes, error in
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
}
