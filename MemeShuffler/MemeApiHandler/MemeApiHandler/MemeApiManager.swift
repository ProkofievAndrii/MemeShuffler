//
//  MemeApiManager.swift
//  MemeApiHandler
//
//  Created by Andrii Prokofiev on 06.07.2024.
//

import Foundation

public class MemeApiManager {
    
    private func requestMemesPortion(using apiParams: (quantity: Int, subredditName: Int), completion: @escaping ([Meme]?) -> Void) {
        var urlString = "https://meme-api.com/gimme/\(apiParams.subredditName)/\(apiParams.quantity)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let memeResponce = try decoder.decode([Meme].self, from: data)
                completion(memeResponce)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    public static func loadMemesCompilation() {
        
    }
}
